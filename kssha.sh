#!/bin/bash
# kills all ssh-agent processes for the current user

ps aux | grep ssh-a | grep $USER | grep -v grep | awk '{print $2}' | xargs sudo kill -9
