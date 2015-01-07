#! /bin/bash

rgbasm -omoving.obj moving.asm;
rgblink -omoving.gb moving.obj;
rgbfix moving.gb;
