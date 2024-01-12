# githubtesting
This issue closely resembles issue 166 about making around-next only affect [one subsequent press](https://github.com/kmonad/kmonad/issues/166). Layer-next is defined in the tutorial:

Layer-next is defined as affecting only one subsequent press: 

```
'layer-next', once pressed, primes KMonad to handle the next press from some
  arbitrary layer.
```

However it really handles next sequence of conjoined presses.

This issue closely resembles issue 166 about making around-next only affect [one subsequent press](https://github.com/kmonad/kmonad/issues/166). 

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

I have tried to create a button similar to the "around-next-single" button that David Janssen created to solve the issue, but for some reason the logic does not apply to layers.


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

I have tried to create a button similar to the "around-next-single" button that David Janssen created to solve the issue, but for some reason the logic does not apply to layers.


Layer-next is defined as affecting only one subsequent press: 

```
'layer-next', once pressed, primes KMonad to handle the next press from some
  arbitrary layer.
```

However it really handles next sequence of conjoined presses.

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

I have tried to create a button similar to the "around-next-single" button that David Janssen created to solve the issue, but for some reason the logic does not apply to layers.


```
layerNextSingle :: LayerTag -> Button
layerNextSingle t = onPress $ await isPress $ \_ -> do
  layerOp (PushLayer t)
  await (pure True) $ \_ -> do
    layerOp (PopLayer t)
    pure NoCatch
  pure NoCatch
```
