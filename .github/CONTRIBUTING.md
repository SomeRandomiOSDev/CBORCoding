## Before getting started

I just want to say a special thanks for looking to improve this project. I truly love the open source community and it wouldn't be what it is today without people like you.

# How to contribute

There are three main ways in which you contribute:

1. Open a [Bug Report](https://github.com/SomeRandomiOSDev/CBORCoding/issues/new?assignees=SomeRandomiOSDev&labels=bug&template=BUG_REPORT.yml&title=%5BBUG%5D%3A+).
2. Open a [Feature Request](https://github.com/SomeRandomiOSDev/CBORCoding/issues/new?assignees=SomeRandomiOSDev&labels=enhancement&template=FEATURE_REQUEST.yml&title=%5BFEATURE%5D%3A+).
3. Create a [Pull Request](https://github.com/SomeRandomiOSDev/CBORCoding/compare).

> If none of these really suit your needs, you could also open a [blank issue](https://github.com/SomeRandomiOSDev/CBORCoding/issues/new).

If you need further guidance or have additional questions, you can always reach out at

* somerandomiosdev@gmail.com

Please also note we have a [code of conduct](#code-of-conduct), please follow it in all your interactions with the project.

## Getting started

For contributing via *Bug Reports* or *Feature Requests* contribuing is as simple as opening that specific issue. 

> We use GitHub issue forms for submitting these types of issues. For reference, those form templates can be found [here](ISSUE_TEMPLATE/BUG_REPORT.yml) for Bug Reports and [here](ISSUE_TEMPLATE/FEATURE_REQUEST.yml) for Feature Requests.

For contributing via *Pull Requests*, we ask the following of you prior to opening a `pull request` to help maintain code standards and quality (many of these are enforced with workflows, but who wants to push subsequent commits for a single PR?):

* Please try and follow the implicit code conventions and naming schemes present within the project.
* All Swift files for this project lint successfully. The latest version of SwiftLint should be used for linting.
* The builds for all platforms should succeed, along with all of the unit tests for each platform.
* Any new code added should be accompanied by appropriate unit test code to cover (virtually) all cases and paths through that code. The code coverage for this project shouldn't decrease by a significant amount, but increases in code coverage are always welcome and appreciated.
* Any new public APIs added should be accompanied by documentation in code, and as appropriate, in the [README](../README.md) file and in the Documentation Catalog.
* Since this project is available via [CocoaPods](https://cocoapods.org), it should lint successfully for both `pod lib lint` and `pod lib lint --use-libraries` using the latest version of the `pod` utility.

> Tip: It's strongly recommended to use the [workflowtests.sh](../scripts/workflowtests.sh) script for testing all of the various builds & linting as this script is a mirror of the workflows that are ran for `pull requests`.

For further guidance about requirements for `pull requests`, please see the [Pull Request Guidelines](PULL_REQUEST_TEMPLATE.md) document.

## Code of Conduct

As far as it pertains to contributions to this project, we do not and will not discriminate against people on any grouds aside from those contributions. Furthermore, discrimination from other persons will not be tolerated in any capacity. 

We may, at our own discretion, remove, block from commenting/contributing, or otherwise persons who violate these guideline or those laid out below in order to maintain and inclusive productive community.

For the full text of these guidelines, please read the [CODE_OF_CONDUCT](CODE_OF_CONDUCT.md) document.
