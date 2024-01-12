I want to switch into another layer for one keypress only. 

Layer-next is defined in the tutorial as affecting only one subsequent press: 

```
'layer-next', once pressed, primes KMonad to handle the next press from some
  arbitrary layer.
```

However, it really handles multiple next presses if they are pressed together.

This issue applies to around-next also, and closely resembles  [#166](https://github.com/kmonad/kmonad/issues/166)
and [#167](https://github.com/kmonad/kmonad/pull/167).

### Steps to reproduce the issue

To borrow the examples from #167, suppose I have

```
(defalias
  nsh (layer-next sft))
```

Assuming layer "sft" has capitalised all alpha keys like Q W E R T Y

### Expected behaviour

I expect to see the layer used for only one keypress.

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> Ab
```

### Actual/current behaviour

But if many keys are pressed together they are all made in the layer.

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> AB
```

### Attempt to create a button

David Janssen created an "around-next-single" button (discussed in this [comment](https://github.com/kmonad/kmonad/issues/166#issuecomment-774505779)) to solve the around-next issue. I attempted to use that logic but the behaviour was no different to layer-next.

```
layerNextSingle :: LayerTag -> Button
layerNextSingle t = onPress $ await isPress $ \_ -> do
  layerOp (PushLayer t)
  await (pure True) $ \_ -> do
    layerOp (PopLayer t)
    pure NoCatch
  pure NoCatch
```

### Other ways of doing this

This can be done by creating layers full of aliases whose only function is to perform one key and return but it uses a lot of config space.

Or maybe there is some other way?
