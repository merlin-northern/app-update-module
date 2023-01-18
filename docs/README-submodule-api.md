# Applications updates

Application update module (App Update Module), being the regular Mender Update Module,
contains and implements all the logic behind the deployment of any application to a device.
As of the moment of writing this the first implementation takes care of containers-based
applications.

There are many ways to deploy an application to a device. One of them is: containers.
There is a number of available solutions which allow you to declare what images
constitute your deployment and how to assemble it, these we will call _orchestrators_
and all the declarations needed _manifests_. Among the most popular orchestrators
we have kubernetes and docker compose. We will refer to them as _k8s_ and _docker-compose_,
respectively. In both cases there is a common set of operations and common logic behind
them required for the applications updates to happen. We implement it in the general `app`
update module, and provide the so-called orchestrator sub-module API to delegate
the orchestrator specific implementations to separate modules. We will refer to them as
_sub-module API_ and sub-modules respectively.

## Orchestrator sub-module API

The Mender App Update Module reads the given artifact. Using `orchestrator` field it calls
a sub-module by name, for a predefined location:

```shell
 # tree /usr/share/mender/app-modules/v1/
/usr/share/mender/app-modules/v1/
├── docker-compose
└── k8s
...
 # tree /usr/share/mender/modules/v3/
/usr/share/mender/modules/v3/
├── app
├── deb
├── directory
├── docker
├── mender-configure
...
```

The above figure shows the App Update Module (`/usr/share/mender/modules/v3/app`) and sub-modules
located in `/usr/share/mender/app-modules/v1/`. File names in the latter directory
are the orchestrators names.

### API reference

#### EXPORT_MANIFEST
Allows to export the currently running composition, in the form that allows to call ROLLOUT
with it, and also in the same form that it comes from the upstream (with the arifact).
We need this to perform the ROLLBACK and it means that we must store the manifest(s) somewhere.

Parameters: `output_directory` -- a directory that will contain the manifest

#### EXPORT image
Allows to export an image (e.g: ctr export images) to a file

Parameters: `image_url` -- a url for image to export. May contain the sha256 (or other sum)
after `@` sign, in which case we check if the sums match

#### IMPORT image
Allows to import an image from a file (e.g.: docker import < image.tar)

Parameters: `image_url` -- a url for image to export. May contain the sha256 (or other sum)
after `@` sign, in which case we check if the sums match

#### LS_IMAGES
Allows to list the images in the composition

#### DELETE image
Allows to remove a given image

Parameters: `image_url` -- a url for image to export. May contain the sha256 (or other sum)
after `@` sign, in which case we check if the sums match

#### ROLLOUT directory
Deploys the given composition

Parameters: `source_directory` -- directory containing the manifests. In case of k8s
it is a directory where we run apply, or docker-compose up in case of docker-compose.

#### ROLLBACK
Rolls back the composition to a previous working state

#### ALIVE
Returns true if composition is live

#### HEALTHY
Returns true if composition is healthy

### Additional settings

If we think about {{k8s}} we can imagine elements of an application running in different
namespaces, or requiring some mangling of contexts, or authorization. Instead of creating
a set of non-portable arguments to, e.g., [ROLLBACK](#rollback) call, we can pass
the required data in variables, providing them in environment when we call sub-modules.
When and if needed, we can provide it in the artifact metadata (for non-confidential),
or inside the artifact in an encrypted manner, using device private key, for instance.
All this would require some modifications, but is doable, and maybe considered
for next iterations.