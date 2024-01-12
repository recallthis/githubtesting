# githubtesting

Layer-next is defined in the tutorial as affecting only one subsequent press: 

```
'layer-next', once pressed, primes KMonad to handle the next press from some
  arbitrary layer.
```

However, it really handles next sequence of conjoined presses

This applies to around-next too and closely resembles issue #167 and resolution #169

[Is there a version of tap-next that affects only one subsequent press? #166](https://github.com/kmonad/kmonad/issues/166)

[Make around-next only affect the next button #167](https://github.com/kmonad/kmonad/pull/167)

So to use the minilanguage, suppose I have

```
(defalias
  nsh (layer-next sft))
```

And layer "sft" is a layer with keys like Q W E R T Y

Then the current layer-next behaviour will give

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> AB
```

while the expected behaviour would be

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> Ab
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
