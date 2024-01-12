# githubtesting

Layer-next is able to change more buttons than just the very next one, provided the next button is released after some other buttons were pressed.

For example, suppose we had

```
(defalias
  nsh (around-next sft))
```

Then the old behaviour would give

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> AB
```

while the intended behaviour (and the one that this commit introduces)
would be

```
T@nsh Ta Tb       ==> Ab
T@nsh Pa Pb Ra Rb ==> Ab
```

Sound familiar? :D That is because this issue mirrors the around next issue, in that the layer-next has the same issue as around-next.

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
