!bquote
gbox-template is a template and guide that allows the rapid creation of a gbox.
!equote

===== Prerequisites =====

You mainly need a working copy of "Docker": "http://docker.com". It is used
exclusively to manage system configurations for running numerous tools
across numerous platforms.

If you are on Windows 10 you can install the Windows Insider edition 
and set up "WSL2": "https://docs.microsoft.com/en-us/windows/wsl/wsl2-install". 
It is recommended you create a group for docker and add your user 
to the "docker group": "https://docs.docker.com/engine/install/linux-postinstall/".
The performance of WSL2 is fairly good -- however, you will want to ensure you set
a memory limit for your installation is garbage collection may still have difficulty.

===== Installation =====

All docker images are at "https://hub.docker.com/u/granatumx".
All github repos are at "https://github.com/granatumx/*".

First set up your scripts and aliases to make things easier. This command should pull the container if
it does not exist locally which facilitates installing on a server.
!bc sys
source <( docker run --rm -it granatumx/scripts:1.0.0 gx.sh )
!ec

This command makes `gx` available. You can simply run `gx` to obtain a list of scripts available.

The GranatumX database should be running to install gboxes. The gbox sources do not need to be installed.
A gbox has a gbox.tgz compressed tar file in the root directory which the installer copies out and uses
to deposit the preferences on the database. Since these gboxes are in fact docker images, they will be
pulled if they do not exist locally on the system. Convenience scripts are provided for installing specific gboxes.

!bc sys
$ gx run.sh                                        # Will start the database, taskrunner, and webapp
$ gx installGbox.sh granatumx/gbox-template:1.0.0  # Install this gbox
!ec

===== Building =====

For the most part, everything is self-contained. Building can be done within the gbox itself,
but probably easier to look at the Dockerfile and install the utilities on the host system.

!bc sys
$ make doc               # Build your documentation if you use README.do.txt
$ make docker            # Will create the local docker image
$ make docker-push       # You probably want to rename so it pushes to your docker repo
!ec

===== Creating a gbox =====

GranatumX is the sequel to Granatum, a graphical single-cell RNA-seq (scRNA-seq) analysis pipeline for genomics scientists.

In GranatumX, developers can add modules--in any language of their choice--that other biologists and bioinformaticians can arrange into analysis pipelines using a user-friendly web UI. The below guide contains brief instructions on how to develop a Gbox.


First, you'll want the GranatumX source code so you can install and run GranatumX on your own machine.
Use the installation steps above.

After installation (which may take a while), GranatumX should be running at http://localhost:34567. 
Once you've verified GranatumX is running you can continue building your package. You can clone the
granatumx/gbox-template or pull the docker image.

You can setup your `Dockerfile` as you like. Change the MAINTAINER field. Also modify the `Makefile` to 
use the appropriate docker image name for where you want the docker image to reside. You can do it entirely
locally if you wish to do so (does not require a DockerHub username/password).

=== YAML definitions ===

A key requirement of a GranatumX Gbox is the package.yaml file. In this file you'll add descriptive information about your Gbox, information about the backend scripts your Gbox uses to perform its operations, and definitions for the frontend user inferface of your Gbox. The file will look something like the below. Note that `{VER}` and `{GBOX}` are replaced
with the names you supply in the `Makefile`.

!bc yaml
id: TransposerPackage-{VER}
meta:
  maintainer:
    name: Your Name
    email: your.name@gmail.com
gboxes:
  - id: TransposerPackage-{VER}
    meta:
      title: TransposerPackage {VER}
      subtitle: Example RNA seq package that transposes a matrix
      description: |
        This is a template package. You can use this package as a starting point for your own package.
    endpoints:
      backend:
        type: docker
        image: {GBOX}
        cmd: python ./main.py
    frontend:
      args:
        - type: seed
          injectInto: seed
          default: 12345
          label: Random seed
          description: >
            A random seed
        - type: number
          injectInto: someInput
          default: 2000
          label: Some number
          description: Example of a number input
      imports:
        - kind: assay
          label: Assay
          injectInto: assay
      exports:
        - kind: assay
          extractFrom: Transposed assay
!ec

For a full description of all available fields, check out the "gbox_installer/jsonSchemas/IGboxSpec.json" file. Two key fields are briefly described below.

The "endpoints" field contains the logic which will connect a user's pipeline to your Gbox backend. In this example, the Gbox backend is a docker image, and the command to be executed when the user runs your Gbox is "python ./main.py". You can look at the g_packages folder for examples of other backend configuration options.

The "frontend" field contains the "args" section defining what HTML inputs to show the user (these serve as the arguments which will be passed to your Gbox), the "imports" section defining what types of inputs from other Gboxes your Gbox accepts, and the "exports" section defining the types your Gbox exports to other Gboxes.

=== Dockerfile ===

The next part of your package to look at is your Dockerfile. A starter Dockerfile may look like the below. A starter Dockerfile may look like the below. The one supplied in the current image is a bit more sophisticated but too long to include here.
It is suggested you visit the "docker page": "https://docs.docker.com/get-started/part2/" on creating Dockerfiles.

!bc
FROM python:3.6.4

MAINTAINER "Your Name" your.name@gmail.com

WORKDIR /usr/src/app

CMD [ "echo", "HelloWorld" ]
!ec

This Dockerfile creates an image with Python 3.6.4 and displays a HelloWorld message on startup.

You can update this Dockerfile with anything your Gbox needs for its operation. You can also start with an R base image, a Julia base image, or any other image you require.

=== Guts ===

Now you can start writing your actual application code. The Python code below implements a simple transpose operation using the GranatumX SDK.

!bc python
import granatum_sdk
import numpy as np

# Demonstration of a Gbox that transposes a Gene Expression Matrix
def main():
    gn = granatum_sdk.Granatum()
    assay = gn.get_import("assay")
    seed = gn.get_arg("seed")
    assay["matrix"] = np.array(assay.get("matrix")).T

    gn.export_statically(assay, "Transposed assay")
    gn.add_result("Matrix successfully transposed", data_type="markdown")
    gn.commit()

if __name__ == "__main__":
    main()
!ec

Note that the `granatum_sdk` is a library of functions that facilitate currying data to and from the gbox. It is 
written in Python (`granatum_sdk/`) and R (`granatum_sdk.R`). You can easily translate to your favorite language.

The above code demonstrates how to get user inputs, get data inputs, and post data back to a GranatumX session.

=== And done... ===

To install, execute the utility shown above.

!bc sys
$ gx run.sh                                   # Will start the database, taskrunner, and webapp
$ gx installGbox.sh {your gbox coordinates}   # Install this gbox
!ec

Now return to http://localhost:34567, choose "add step" and you should see your gbox available.
