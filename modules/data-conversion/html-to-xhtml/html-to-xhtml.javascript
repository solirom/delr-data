const cheerio = require('cheerio');
const fs = require('fs');
const iconv = require('iconv-lite');
const request = require('request');

const inputDir = "input";
const tmpDir = "tmp";
const outputDir = "output";

fs.rmdirSync(outputDir, {recursive: true});
fs.rmdirSync(tmpDir, {recursive: true});

if (!fs.existsSync(tmpDir)){
    fs.mkdirSync(tmpDir)
  }
fs.mkdirSync(outputDir, 0744);

fs.readdirSync(inputDir).forEach(file => {
    fs.createReadStream(inputDir + "/" + file)
        .pipe(iconv.decodeStream("win1250"))
        .pipe(iconv.encodeStream("utf-8"))
        .pipe(fs.createWriteStream(tmpDir + '/' + file));
        
    fs.readFile(tmpDir + '/' + file, {encoding: 'utf8'}, function(err, fileContent) {
        if (!err) {
            fileContent = fileContent.replace(/&nbsp;/g, " ");
            console.log(fileContent);
            
            const $ = cheerio.load(fileContent, {decodeEntities: false});
            
            var htmlContent = $("body").html();

            Object.keys(replacements).forEach(key => {
                htmlContent = htmlContent.replace(new RegExp(key, 'g'), replacements[key]);
            });            
            
            htmlContent = generateHtmlPage(htmlContent);
            console.log(htmlContent);        

            fs.writeFile(outputDir + '/' + file, htmlContent, {encoding: 'utf8'}, function (err) {
                if (err) return console.log(err);
                console.log("Procesat fișierul: " + file);
            });
        }
    });  
 });

function generateHtmlPage(content) {
    return '<html xmlns="http://www.w3.org/1999/xhtml"><head><title></title><meta charset="utf-8"/></head><body>' + content + '</body></html>';
}

const replacements = {
    "<(div)[^>]+>": "<$1>",
    "<(p)[^>]+>": "<$1>",
    "<(span)[^>]+>": "<$1>",
    "<br[^>]+>": "",
    "ţ": "ț",
    "ş": "ș",
    "(s*)<( |\\r|\\n|<|-)": "$1&lt;$2", 
    //"><<", ">&lt;<"
    "[ ]+": " "
};
