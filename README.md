mmm-bat [![Build Status](https://api.travis-ci.org/vmfhrmfoaj/mmm-bat.png?branch=develop)](http://travis-ci.org/vmfhrmfoaj/mmm-bat)
=======

Android mmm build and generate the bat file that push a newly installed binary files.

```
Usage:
    mmm-bat <dir> <product name> <-a>

    - dir: path for build
           e.g) hardware/qcom/camera
    - product name: product string for mmm-build.
                    If the product name is "custom", to execute the "mmm-bat-custom.sh" file.

Optional:
    - append mode(-a): To accumulate a push list.
```
