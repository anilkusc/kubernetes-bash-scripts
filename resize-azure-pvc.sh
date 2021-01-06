#!/bin/bash
EDITOR=nano
#Resizing azure pvc
kubectl edit sc default
#change: allowVolumeExpansion: true 
kubectl edit pvc <pvc-name>
#editin pvc.Resize first volume (under the acces modes) only and save it.
#Restart pod
kubectl delete pod <pod-name>
