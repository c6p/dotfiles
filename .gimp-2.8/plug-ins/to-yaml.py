#!/usr/bin/env python

from gimpfu import *
import os
import yaml

def to_yaml(img, drawable):
    name = pdb.gimp_image_get_filename(img)
    if not name:
        pdb.gimp_message("Export Layers to YAML: File NOT saved!")
        return;

    # PNG
    name = os.path.splitext(name)[0]
    name_png = name + ".png"
    basename_png = os.path.basename(name_png)

    layer = pdb.gimp_layer_new_from_visible(img, img, "_MERGED_")
    pdb.file_png_save_defaults(img, layer, name_png, basename_png)

    # YAML
    name_yaml = name + ".yaml"
    d = { 'load': basename_png, 'textures': [] }
    yt = d['textures']
    for layer in img.layers:
        if pdb.gimp_item_get_visible(layer):
            yt.append({ 'name': layer.name })
            ytb = yt[-1]
            if not pdb.gimp_item_is_group(layer):    # no children
                ytb['type'] = "image"
                ytb['coords'] = [ layer.offsets[0], layer.offsets[1],
                        layer.width, layer.height ];
            else:                   # have children
                ytb['type'] = "imagelist"
                ytb['coords'] = []
                for i in pdb.gimp_item_get_children(layer)[1]:
                    l = gimp.Item.from_id(i)
                    if pdb.gimp_item_get_visible(l):
                        ytb['coords'].append([l.offsets[0], l.offsets[1],
                            l.width, l.height])

    with open(name_yaml, 'w') as f:
        dump = yaml.dump(d)
        f.write(dump)

# Register with The Gimp
register(
    "to_yaml",
    "Export visible layers to YAML",
    "Export visible layers to YAML",
    "Can Altiparmak",
    "(c) 2014, Can Altiparmak",
    "2014-10-18",
    "<Image>/Filters/Export Visible Layers to YAML",
    "*",
    [
    ],
    [],
    to_yaml);


main()

