## This module contains utility functions for analysing XmlNode-structures
import xmlparser, xmltree
import sugar, options, strtabs, sequtils

proc hasAttr*(x: XmlNode, t: string): bool =
  ## Returns true if the given node `x` has an attribute
  ## with the name `t`
  let atts = x.attrs()
  if atts != nil and atts.hasKey(t):
    return true
  return false

  
proc getAttr*(n: XmlNode, a: string): string =
  ## Returns the attribute `a` and throws an exception if the node `n`
  ## does not have a matching attribute
  let atts = n.attrs()
  if atts==nil or (not atts.hasKey(a)):
    raise newException(Exception,
                       "Node does not have required attribute '" & a & "'")
  return atts[a]


# Predicates
# Predicates are used to find nodes with specific properties (tags,
# attributes, subnodes, ...)
# Use them with functions like getByPred() or findByPred()
type
  Pred* = (x: XmlNode) -> bool
  
  FindOption* = enum
    ## Specifies whether only the direct children of a node should
    ## be searched or if the function should work recursively
    foDirect,
    foRecursive

proc fulfills*(x: XmlNode, p: Pred): bool =
  ## Returns true if the node `x` fulfills the predicate
  ## Returns false otherwise
  return p(x)

proc expect*(x: XmlNode, p: Pred, msg: string =
             "Node does not fulfill requirements"): bool =
  ## Raises an exception if node `x` does not fulfill predicate `p`
  if not p(x):
    raise newException(Exception, msg)

proc `<&>`*(lhs: Pred, rhs: Pred): Pred =
  ## Combines two predicates together. Combined predicate will only
  ## evaluate to true if both predicates evaluate to true
  return proc(x: XmlNode): bool =
             return lhs(x) and rhs(x)
             

proc hasAttr*(t: string): Pred =
  ## Returns a predicate which returns true if the given node has
  ## the attribute `t`
  return proc (x: XmlNode): bool =
             let atts = x.attrs()
             return (atts != nil and atts.hasKey(t))

proc hasAttr*(a, v: string): Pred =
  ## Returns a predicate which returns true if the given node has
  ## the attribute `t` and it's value is equal to `v`
  return proc (x: XmlNode): bool =
            if not x.hasAttr(a):
               return false
            return x.getAttr(a) == v
             
proc hasTag*(t: string): Pred =
  ## Returns a predicate which returns true if the given node's tag
  ## is equal to `t`
  return proc (x: XmlNode): bool =
             return x.tag() == t

proc hasSubnode*(subnodePred: Pred, fo: FindOption=foDirect): Pred =
  ## Returns a predicate which returns true if the given node has a
  ## subnode which fulfills the given predicate.
  ## Respects the FindOption `fo`
  return proc(x: XmlNode): bool=
            for child in x:
              if child.kind()==xnElement:
                if subnodePred(child):
                  return true
                if fo==foRecursive:
                  if child.fulfills(hasSubnode(subnodePred, fo)):
                    return true
            return false
          

             
# End of Predicates

             
proc findByPred*(parent: XmlNode, pred: Pred,
                fo: FindOption = foRecursive): seq[XmlNode] =
  ## Returns all children (recursive if specified by fo) which fulfill
  ## the given predicate
  result = @[]
  if parent.kind() != xnElement:
    return result
  for child in parent:
    if child.kind()!=xnElement:
      continue
    if pred(child):
      result.add(child)
    if fo==foRecursive:
      result.add(child.findByPred(pred, fo))
  return result

proc getByPred*(parent: XmlNode,pred: Pred,
               fo: FindOption = foRecursive): Option[XmlNode] =
  ## Returns the first occurence of a child which fulfills the given
  ## predicate. Respects the FindOption fo
  let r = parent.findByPred(pred, fo)
  if r.len()==0:
    return none[XmlNode]()
  else:
    return some(r[0])

proc getPathTo*(parent: XmlNode, target: XmlNode, level: int = 0): seq[XmlNode] =
  if parent==target:
    return @[target]
  else:
    for child in parent:
      if child.kind() != xnElement:
        continue
      let res = child.getPathTo(target, level+1)
      if res.len()==0:
        continue
      else:
        result = @[parent]
        result.add(res)
        return result
    return @[]
