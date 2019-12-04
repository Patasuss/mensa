import nim_utils, xml_utils, strtabs, strutils
import tables, xmltree, htmlparser, httpclient

var client = newHttpClient()
let htmlContent = client.getContent("https://www.stw-bremen.de/de/mensa/uni-mensa")
let html = htmlContent.parseHtml()

let foodPlans = html.getByPred( hasTag("div") <&> hasAttr("class", "food-plans")).unwrap("Could not get food plans node")
let tableNodes = foodPlans.findByPred( hasTag("table") <&> hasAttr("class", "food-category") )

var foundCategories = initTable[string, bool]()

for tableNode in tableNodes:
  let
    categoryNode = tableNode.getByPred( hasTag("th") <&> hasAttr("class", "category-name")).unwrap("Could not get category node")
    category = categoryNode.innerText
  if foundCategories.hasKey(category):
    continue
  foundCategories[category] = true

  let
    priceNode = tableNode.getByPred( hasTag("td") <&> hasAttr("class", "field field-name-field-price-students")).unwrap("Could not get price node")
    price = priceNode.innerText

  let
    descriptionNode = tableNode.getByPred( hasTag("td") <&> hasAttr("class", "field field-name-field-description") ).unwrap("Could not get description node")
  var description: string = ""
  for i in descriptionNode:
    if i.kind() == xnText:
      let t = i.innerText.replace("\n", " ").strip()
      if t.len()>1 and t!="\n":
        description.add(" " & t)

  echo category, " - ", price
  echo "   ", description
  echo ""
