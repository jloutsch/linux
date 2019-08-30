#!/bin/bash
session="flask_app"

tmux start-server

tmux new-session -d -s $session  -n code
tmux send-keys "laptop" C-m
tmux send-keys "flask_app" C-m
tmux send-keys "cd backend/src/flask_app; ls -l" C-m

tmux split-window -v
tmux send-keys "laptop" C-m
tmux send-keys "flask_app" C-m
tmux send-keys "cd frontend/src; ls -l" C-m

tmux new-window -n server
tmux send-keys "laptop" C-m
tmux send-keys "pkill flask; flask_app_run" C-m

tmux split-window -v
tmux send-keys "laptop" C-m
tmux send-keys "pkill node; flask_app_frontend" C-m

tmux new-window -n database
tmux send-keys "ssh db" C-m
tmux send-keys "sudo -u postgres /usr/pgsql-11/bin/psql -d flask_app" C-m

tmux select-window -t code
tmux attach-session -t $session
