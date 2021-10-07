# Ansible Multi-Machine Template

## Description

A vagrant multi-machine setup with Arch Linux - Used for testing out ansible configuration

Creates:
- a manager node with ansible pre-installed and configured with ssh access to worker nodes
- *numworker* worker nodes named `worker[n]` where `[n] = 1..numworker` - Note: *numworker* can be configured in [config.yaml](./config.yaml)

The system can be configured by updating settings in [config.yaml](./config.yaml)

## Verified Working With

* vagrant 2.2.18, with plugins:
  * vagrant-betterhosts 0.2.1
* VirtualBox 6.1.26
