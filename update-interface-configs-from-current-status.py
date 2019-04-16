#!/usr/bin/python
# -*- coding: utf-8 -*-

import subprocess as sp
import re
import os
import sys
import datetime


def main():
    currentInterfaceStatuses = getInterfaceStatuses()

    configIsChanged = False
    for cis in currentInterfaceStatuses:
        interface = cis[0]
        status = cis[1]

        interfaceConfig = \
            '/etc/sysconfig/network-scripts/ifcfg-{0}'.format(interface)
        try:
            persistentConfigValues = \
                parseInterfaceConfig(interfaceConfig)
        except IOError, e:

            # The config file didn't exist (or we don't have permissions). We can
            # safely skip

            continue

    # Check if we have the minimum settings configured. If the file isn't correct,
    # then just skip so we don't screw anything up. This script isn't intended to be
    # advanced enough to handle strange configurations

        configKeys = persistentConfigValues.keys()
        requiredKeys = ['ONBOOT', 'DEVICE', 'BOOTPROTO']
        if not all(map(lambda x: x in configKeys, requiredKeys)):
            print 'missing options for interface: {0}'.format(interface)
            continue

    # Apply persistent changes if current link status differs from persistent settings

        if (status == 'UP' or interface == 'lo') \
            and persistentConfigValues['ONBOOT'].lower() == 'no':
            persistentConfigValues.update({'ONBOOT': 'yes'})
            writeInterfaceConfig(interfaceConfig,
                                 persistentConfigValues)
            configIsChanged = True
        elif status == 'DOWN' and persistentConfigValues['ONBOOT'
                ].lower() == 'yes':

            persistentConfigValues.update({'ONBOOT': 'no'})
            writeInterfaceConfig(interfaceConfig,
                                 persistentConfigValues)
            configIsChanged = True
    if configIsChanged:
        restartNetworkService()


def getInterfaceStatuses():
    """
    Returns list of tuples containing the form
    [(interface, status), ...]
    """

    ipOutput = runIpLink()
    outputLines = ipOutput.split('\n')
    matchedInterfaces = matchInterfaces(outputLines)
    interfaceNames = map(lambda x: (x.group('interface'),
                         x.group('status')), matchedInterfaces)
    return interfaceNames


def runIpLink():
    """ Returns string of unparsed output """

    return sp.Popen(['ip', '-br', 'link'],
                    stdout=sp.PIPE).communicate()[0]


def matchInterfaces(lines):
    """
    Returns list of sre.SRE_MATCH objects.
    Captures named group 'interface', and 'status'
    """

    return filter(lambda x: x, map(lambda x: \
                  re.search('(?P<interface>^.*?)\s+(?P<status>\w+)\s',
                  x), lines))


def parseInterfaceConfig(config):
    """ Parses ifcfg file and returns the key value pairs as a dictionary """

    values = dict()
    with open(config, 'r') as f:
        for line in f:
            (name, val) = line.partition('=')[::2]
            if val:
                val = val.strip('\n')
                values[name] = val
    return values


def writeInterfaceConfig(configFile, configValues):
    with open(configFile, 'w') as f:
        f.write('# Generated from {0} at {1}\n'.format(sys.argv[0],
                datetime.datetime.now()))
        for (key, val) in configValues.items():
            line = '='.join([key, val])
            f.write(line + '\n')


def restartNetworkService():
    sp.Popen(['systemctl', 'restart', 'network']).wait()


if __name__ == '__main__':
    main()
