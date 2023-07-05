# CardsControls
 
UI controls for creating card game. Include:

## CardContainer
Node for ordering children(cards) at row or at arc.

## CardControll
Node that represent card. Have basic card behaviour.  
***Please set Custom minimus size in Layout section to avoid setting size to ZERO by CardContainer.***

**Signals:**  
hovered - emmited when mouse over card. Emmited after standart mouse_entered signal.  
left - emmited when mouse left card.  Emmited after standart mouse_exited signal.  
selected - emmited when left mouse button pressed down.  
aim(coords : Vector2) - emmited when drag mouse with left mouse button pressed.  
apply(coord : Vector2) - emmited when left mouse button up outside card.  

_To add your own functionality for cards or container, just extend script.  
See ExampleScene.tscn_
