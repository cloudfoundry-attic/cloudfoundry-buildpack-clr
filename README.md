## cloudfoundry-buildpack-clr

Buildpack for CLR frameworks like ASP.NET and .NET standalone apps

For more information on the buildpack API, see https://devcenter.heroku.com/articles/buildpack-api.

### Installing the Buildpack

In CloudFoundry v166, buildpacks were removed from the DEA.  The DEA now downloads the necessary buildpacks at runtime.  Starting with IronFoundry v168 or newer, you will need to add this buildpack to your environment using the following command:

```
cf create-buildpack clr_buildpack https://github.com/cloudfoundry-incubator/cloudfoun
dry-buildpack-clr/archive/v1.zip 5
```

You can optionally download the above .zip file and rename it to `buildpack_clr_v1.zip` to be consistent with the built-in buildpacks.

The format of the `create-buildpack` command is:
```
NAME:
   create-buildpack - Create a buildpack

USAGE:
   cf create-buildpack BUILDPACK PATH POSITION [--enable|--disable]

TIP:
   Path should be a zip file, a url to a zip file, or a local directory. Position is an integer, sets priority, and is sorted from lowest to highest.

OPTIONS:
   --enable	Enable the buildpack
   --disable	Disable the buildpack
```


