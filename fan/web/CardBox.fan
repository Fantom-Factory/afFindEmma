using dom

**
** CardBox lays out child elements as a stack of cards, where
** only one card may be visible at a time.
**
** See also: [docDomkit]`docDomkit::Layout#cardBox`
**
@Js class CardBox : Elem
{
  new make() : super()
  {
    this.style.addClass("domkit-CardBox")
  }

  ** Selected card instance, or null if no children.
  Elem? selItem()
  {
    selIndex==null ? null : children[selIndex]
  }

  ** Selected card index, or null if no children.
  virtual Int? selIndex
  {
    set
    {
      old := &selIndex
      &selIndex = it.max(0).min(children.size)
      if (old != &selIndex) updateStyle
    }
  }

  protected override Void onAdd(Elem c)    { updateStyle }
  protected override Void onRemove(Elem c) { updateStyle }

  private Void updateStyle()
  {
    // TODO:
    //   currently require style.width/height to be set on CardBox
    //   should probalby check, or throw if not configured?

    kids := children

    // implicitly select first card if not specified
    if (kids.size > 0 && selIndex == null) selIndex = 0

    // if effect is set, stage the card we will show next
    cur  := kids.find |k| { k.style->display == "block" }
    next := null
    size := null

    // if cur is selected short-circuit effect
    if (cur == null) cur = next
    if (cur === next) { next=null }
    curIndex := kids.findIndex |k| { k == cur }

	updateDis
  }

  private Void updateDis()
  {
    children.each |kid,i|
    {
      kid.style->display = i==selIndex ? "block" : "none"
      kid.style->opacity = "1.0"
    }
  }
}