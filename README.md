llrf-tools
===

Decouple the subystem specific application (llrf-tools) from e3 as a standalone applications.


## Possible proposal

* doesn't support cc, but only host linux86_64
* make init      : clone m-kmod-sis8300 is renamed as sis8300drv (only care src/main/c/lib)
* make build     : build all in build-dir (src and sis8300drv)
* make install   : put binary files into ${HOME}/bin 
* make clean     :
* make uninstall :
```

