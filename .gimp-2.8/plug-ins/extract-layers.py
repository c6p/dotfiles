#!/usr/bin/env python

from gimpfu import *
import os

def extract_layer(img, layer, path):
    if pdb.gimp_item_get_visible(layer):
        name = path + '/' + layer.name
        if pdb.gimp_item_is_group(layer):
            if not os.path.exists(name):
                os.mkdir(name)
            for l in layer.layers:
                extract_layer(img, l, name)
        else:
            tmp_layer = layer.copy()
            name_png = name + '.png'
            pdb.gimp_image_insert_layer(img, tmp_layer, None, -1)
            pdb.plug_in_autocrop_layer(img, tmp_layer)
            pdb.file_png_save_defaults(img, tmp_layer, name_png, os.path.basename(name_png))
            pdb.gimp_image_remove_layer(img, tmp_layer)

def extract_layers(img, drawable, path):
    pdb.gimp_image_undo_freeze(img)
    for layer in img.layers:
        extract_layer(img, layer, path)
    pdb.gimp_image_undo_thaw(img)


# Register with The Gimp
register(
    "extract_layers",
    "Extract Visible Layers",
    "Extract Visible Layers",
    "Can Altiparmak",
    "(c) 2015, Can Altiparmak",
    "2015-01-24",
    "<Image>/Filters/Extract Visible Layers",
    "*",
    [
        (PF_DIRNAME, "path", "Extract to directory:", 0)
    ],
    [],
    extract_layers);

main()

