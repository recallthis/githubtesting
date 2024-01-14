
I was using a later commit from Jun 2021 ([Add logo to README #277](https://github.com/kmonad/kmonad/commit/e3e0154e7d3d37e94980a8c9274ed39d4a860ecc))

I tried the first layer-next commit that [Added leader-key like button](https://github.com/kmonad/kmonad/commit/de85686be1a26cffa7e0dc1c2dcdffae452c86e8)

And the [v0.4.1 prerelease](https://github.com/kmonad/kmonad/commit/1ce9d07794c9b1edfa5bc3c15485d79082770b28) from Sep 2020

And #167 [Make aroundNext only affect the next button](https://github.com/kmonad/kmonad/commit/5e4a3d00a54573997fa1f3423265b7ac4e25acb9)

Each time I tried (layer-next mylayer) (around-next (layer-toggle mylayer)).

In these commits, multiple keypresses are handled in the mylayer, provided they are pressed "together" and not pressed and released sequentially.

I don't think I've ever observed behaviour of layer-next like that described in the tutorial, but maybe I haven't used enough versions of kmonad?
