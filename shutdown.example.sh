#!/bin/sh
sshpass -p raspberry ssh -o StrictHostKeyChecking=no pi@localhost 'sudo poweroff'