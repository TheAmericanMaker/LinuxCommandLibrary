# TAGLINE

Convert PNM to SGI image format

# TLDR

**Convert PNM to SGI image**

```pnmtosgi [input.pnm] > [output.rgb]```

**Use RLE compression**

```pnmtosgi -rle [input.pnm] > [output.rgb]```

# SYNOPSIS

**pnmtosgi** [_options_] [_file_]

# PARAMETERS

**-verbatim**
> No compression (default).

**-rle**
> Use RLE compression.

**-imagename** _name_
> Set the image name field stored inside the SGI file.

**-mtime** _seconds_
> Set the modification time stored inside the file.

# DESCRIPTION

**pnmtosgi** converts PNM images to SGI (Silicon Graphics) image format. Part of Netpbm toolkit.

# SEE ALSO

[sgitopnm](/man/sgitopnm)(1), [pnmtorle](/man/pnmtorle)(1)

