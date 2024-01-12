### Description of the issue

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

David Janssen created an "around-next-single" button to solve the around-next issue. I attempted to use that logic for layer-next-single but it was unsuccessful as the behaviour was unchanged.

```
layerNextSingle :: LayerTag -> Button
layerNextSingle t = onPress $ await isPress $ \_ -> do
  layerOp (PushLayer t)
  await (pure True) $ \_ -> do
    layerOp (PopLayer t)
    pure NoCatch
  pure NoCatch
```
