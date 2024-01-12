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

### Expected behaviour

Assuming layer "sft" has all for capitalised keys like Q W E R T Y

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> Ab
```

### Actual/current behaviour

Then the current layer-next behaviour will give

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> AB
```

David Janssen created an "around-next-single" button to solve the around-next issue, and I attempted to duplicate that without success.

```
layerNextSingle :: LayerTag -> Button
layerNextSingle t = onPress $ await isPress $ \_ -> do
  layerOp (PushLayer t)
  await (pure True) $ \_ -> do
    layerOp (PopLayer t)
    pure NoCatch
  pure NoCatch
```
