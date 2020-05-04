# Creating a Gbox

GranatumX is the sequel to Granatum, a graphical single-cell RNA-seq (scRNA-seq) analysis pipeline for genomics scientists.

In GranatumX, developers can add modules--in any language of their choice--that other biologists and bioinformaticians can arrange into analysis pipelines using a user-friendly web UI. The below guide contains brief instructions on how to develop a Gbox.


First, you'll want the GranatumX source code so you can install and run GranatumX on your own machine.


```python
git clone https://gitlab.com/xz/GranatumX
make setup
```

After installation (which may take a while), GranatumX should be running at http://localhost:34567. Once you've verified GranatumX is running you can continue building your package.

The GranatumX source repo contains a template folder with the key files you'll need for your Gbox. To start building your new Gbox, you'll make a copy of this folder. You'll want to substitute the name of your new package for "yourPackageName".


```python
cp gboxTemplate g_packages/yourPackageName
```

A key requirement of a GranatumX Gbox is the package.yaml file. In this file you'll add descriptive information about your Gbox, information about the backend scripts your Gbox uses to perform its operations, and definitions for the frontend user inferface of your Gbox. The file will look something like the below.

```yaml
id: TransposerPackage
meta:
  maintainer:
    name: Arr N. Eh
    email: rneh@gmail.com
buildCommand: 'cd docker && make'
gboxes: 
  - id: TransposerPackage
    meta:
      title: TransposerPackage
      subtitle: 'Example RNA seq package that transposes a matrix'
      description: |
        This is a template package. You can use this package as a starting point for your own package.
    endpoints:
      backend:
        type: docker
        image: gboxTemplate
        cmd: python ./main.py
    frontend:
      args:
        - type: seed
          injectInto: seed
          default: 12345
          label: Random seed
          description: >
            A random seed'
        - type: number
          injectInto: someInput
          default: 2000
          label: Some number
          description: 'Example of a number input'
      imports:
        - kind: assay
          label: Assay
          injectInto: assay
      exports:
        - kind: assay
          extractFrom: Transposed assay
          meta: {}
```


For a full description of all available fields, check out the "gbox_installer/jsonSchemas/IGboxSpec.json" file. Two key fields are briefly described below.

The "endpoints" field contains the logic which will connect a user's pipeline to your Gbox backend. In this example, the Gbox backend is a docker image, and the command to be executed when the user runs your Gbox is "python ./main.py". You can look at the g_packages folder for examples of other backend configuration options.

The "frontend" field contains the "args" section defining what HTML inputs to show the user (these serve as the arguments which will be passed to your Gbox), the "imports" section defining what types of inputs from other Gboxes your Gbox accepts, and the "exports" section defining the types your Gbox exports to other Gboxes.

The next part of your package to look at is your Dockerfile. A starter Dockerfile may look like the below. The one supplied
in the current image is a bit more sophisticated but too long to include here.


```Dockerfile
FROM python:3.6.4

MAINTAINER "Arr N. Eh" rneh@gmail.com

WORKDIR /usr/src/app

CMD [ "echo", "HelloWorld" ]
```

This Dockerfile creates an image with Python 3.6.4 and displays a HelloWorld message on startup.

You can update this Dockerfile with anything your Gbox needs for its operation. You can also start with an R base image, a Julia base image, or any other image you require.

Now you can start writing your actual application code. The Python code below implements a simple transpose operation using the GranatumX SDK.


```python
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

```

The above code demonstrates how to get user inputs, get data inputs, and post data back to a GranatumX session.

Finally, you can install your Gbox with the below command:


```python
cd gbox_installer
yarn run installEverything
```

Now return to http://localhost:34567. You should be able to test your new Gbox in a scRNAseq pipeline!

