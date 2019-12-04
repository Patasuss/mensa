## This module contains general utility functions to supplement nim's
## functionality
import options, terminal, strutils

proc expectLen*[T](s: seq[T], l: int, msg: string = "Unexpected length") =
  ## Raises an exception (with message msg) if the given sequence's
  ## length is unequal to l
  if s.len()!=l:
    raise newException(Exception, msg)

proc expectMinLen*[T](s: seq[T], l: int, msg: string = "Length too small") =
  ## Raises an exception (with message msg) if the given sequence's
  ## length is smaller than l
  if s.len()<l:
    raise newException(Exception, msg)

proc unwrap*[T](o: Option[T], msg: string = "No contained value"): T =
  ## Returns the value stored inside an Option[T], raises an exception
  ## if the option does not contain
  if o.isNone():
    raise newException(Exception, msg)
  else:
    return o.get()

proc clear*[T](s: var seq[T]) =
  s.setLen(0)
    
proc printWarning*(strs: varargs[string]) =
  stdout.setForegroundColor(fgYellow)
  stdout.write "WARNING: "
  stdout.resetAttributes()
  for s in strs:
    stdout.write s
  stdout.write "\n"

proc printError*(strs: varargs[string]) =
  stdout.setForegroundColor(fgRed)
  stdout.write "ERROR: "
  stdout.resetAttributes()
  for s in strs:
    stdout.write s
  stdout.write "\n"

type
  LineBuffer* = ref object
    lines*: seq[string]
  
proc newLineBuffer*(): LineBuffer =
  return LineBuffer(lines: @[])

proc write*(lb: LineBuffer, strs: varargs[string]) =
  lb.lines.add(strs.join(""))

proc writeToFile*(lb: LineBuffer, f: File) =
  for l in lb.lines:
    f.writeLine(l)

proc clear*(lb: LineBuffer) =
  lb.lines = @[]
