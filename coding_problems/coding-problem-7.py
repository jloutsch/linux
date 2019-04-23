#!/usr/bin/env python
import string

def main():
    """
    I thought my solution was messy when i finally got this working.
    I was adamant about coming up with my own solution before looking up
    the answer. After looking up other peoples solutions, mine doesn't seem that ugly.
    In terms of computation time, I'm pretty sure this is as efficient as it can get.
    Unless I'm mistaken, this implementation is successfully using tabulation.
    I ran the decoder with a very a large input and i got my results immediately.
    """
    decoder = Decoder()
    print(decoder.decode('123423'))
    # Returns ['abcdbc', 'lcdbc', 'lcdw', 'awdbc', 'awdw', 'abcdw'] 

class Decoder():
    """
    Given the mapping a = 1, b = 2, ... z = 26, 
    and an encoded message, 
    count the number of ways it can be decoded.

    For example, the message '111' would give 3, 
    since it could be decoded as 'aaa', 'ka', and 'ak'.
    """
    def __init__(self):
        self.mapping = self._createMapping()

    def _createMapping(self):
        letters = string.ascii_lowercase
        mapping = dict()
        for index, letter in enumerate(letters):
            mapping[index + 1] = letter
        return mapping

    def decode(self, message):
        """
        This method decodes a message
        using our custom dictionary
        """
        results = self.solve(str(message))

        return results

    def solve(self, message, current = '', index = '', cache = {}):
        if not cache:
            cache = dict()

        # Path 1
        path1Number = int(message[0])
        path1Current = current + self.mapping[path1Number]
        if not index:
            index = path1Current
        cache[index] = path1Current

        # Path 2
        if len(message) >= 2:
            combined = int(message[0] + message[1])
            if combined <= 26:
                path2Current = current + self.mapping[combined]
                index2 = path2Current
                cache[index2] = path2Current
                if len(message) >= 3:
                    # Solve path 2
                    self.solve(message[2:], path2Current, index2, cache)
        # Solve path 1
        if len(message) >= 2:
            self.solve(message[1:], path1Current, index, cache)

        return list(cache.values())
            

if __name__ == '__main__':
    main()