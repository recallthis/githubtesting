# githubtesting

Layer-next is (like around-next) defined as affecting only one subsequent press: 

```
'layer-next', once pressed, primes KMonad to handle the next press from some
  arbitrary layer.
```

However, it really handles next sequence of conjoined presses

Notice anything familiar?

This closely resembles [issue 166](https://github.com/kmonad/kmonad/issues/166) about making around-next only affect one subsequent press.

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
