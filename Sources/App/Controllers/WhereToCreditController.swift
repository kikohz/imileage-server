//
//  WhereToCreditController.swift
//  Run
//
//  Created by wangxi1-ps on 2017/11/20.
//
import Vapor
import HTTP
import Kanna

final class WhereToCreditController {

    var dropp:Droplet? = nil
    
    func addRoutes(_ drop: Droplet) {
        self.dropp = drop
    }

    func whereCredit(_ req: Request) throws -> ResponseRepresentable {
        if self.dropp != nil {
            guard let alanguage = req.query?["language"]?.string, let airName = req.query?["airname"]?.string , let airClass = req.query?["class"]?.string else {
                throw Abort.badRequest
            }
            return try self.requestHtml("http://www.wheretocredit.com/\(alanguage)/\(airName)/\(airClass)",self.dropp!)
        }
        else {
            throw Abort(.notFound)
        }
    }
    
    func requestHtml(_ url:String,_ drop: Droplet) throws ->ResponseRepresentable {
        print(url)
        let request = Request(method: .get, uri: url)
        let res = try drop.client.respond(to: request)
        let htmlstr = String(bytes: res.body.bytes!)
        return try self.parseHtml(htmlstr)
    }
    
    func parseHtml(_ html:String) throws ->ResponseRepresentable {
        if html.isEmpty {
            throw Abort(.notFound)
        }
        var dataJson = JSON()
        var dataArr = [[String:String]]()
        if let doc = HTML(html: html, encoding: .utf8) {
            // Search for nodes by XPath
            let tdody = doc.xpath("/html/body/div[4]/div[2]/div[1]/div/table/tbody/tr")
            for item:XMLElement in tdody.array {
                let nameElement = item.at_xpath("td[1]/span/a/span")
                let subNameElement = item.at_xpath("td[1]/span/span/span")
                let dateElement = item.at_xpath("td[1]/small/abbr")
                let ratioOneElement = item.at_xpath("td[2]/div")
                let twoElement = item.at_xpath("td[3]/div")
                let threeElement = item.at_xpath("td[4]/div")
                let itemDict = ["airName":self.ratiofilter(ratioStr: nameElement?.text),"subTitle":self.ratiofilter(ratioStr: subNameElement?.text),"date":self.ratiofilter(ratioStr: dateElement?.text),"ratio-1":self.ratiofilter(ratioStr: ratioOneElement?.text),"ratio-2":self.ratiofilter(ratioStr: twoElement?.text),"ratio-3":self.ratiofilter(ratioStr: threeElement?.text)]
                dataArr.append(itemDict)
            }
            try dataJson.set("data", dataArr)
        }
        return dataJson
    }
    
    func ratiofilter(ratioStr:String?) -> String {
        var tempRatioStr = ""
        if let tempStr = ratioStr {
            tempRatioStr = tempStr.trimmingCharacters(in: .whitespaces)
            tempRatioStr = tempRatioStr.replacingOccurrences(of: "\r", with: "")
            tempRatioStr = tempRatioStr.replacingOccurrences(of: "\n", with: "")
            tempRatioStr = tempRatioStr.replacingOccurrences(of: " ", with: "")
        }
        return tempRatioStr
    }
}



