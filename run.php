<?php
ini_set('error_reporting', E_ALL | E_STRICT);
// $owlpath = '/Applications/MAMP/htdocs/myow/libraries/Erfurt/Erfurt/Owl/Structured'; $contents = scandir($owlpath); $includedirs = "";
// $files = array_diff($contents, array(".", "..", ".git", ".idea"));
// foreach ($files as $file) if(is_dir($owlpath.$file)) $includedirs .= PATH_SEPARATOR . $owlpath.$file;
// set_include_path(get_include_path(). PATH_SEPARATOR . $includedirs .PATH_SEPARATOR . $owlpath . PATH_SEPARATOR . "/Applications/MAMP/htdocs/myow/libraries" . PATH_SEPARATOR . "/Applications/MAMP/htdocs/myow/libraries/Erfurt/Erfurt");

set_include_path(get_include_path(). PATH_SEPARATOR . "/Applications/MAMP/htdocs/myow/libraries" . PATH_SEPARATOR . "/Applications/MAMP/htdocs/myow/libraries/Erfurt");

// ini_set("memory_limit","24M");
$time_start = microtime(true);
require_once '/Users/roll/Documents/dropdocs/Dropbox/dropdocs/projects/tmp/svn/runtime/Php/antlr.php';
require_once 'src/StrippedMosNewLexer.php';
require_once 'src/StrippedMosNewParser.php';
require_once 'src/StrippedMosNew_StrippedMosTokenizerNew.php';

// function __autoload($class_name) {require_once $class_name . '.php';}


// Zend_Loader for class autoloading
require_once 'Zend/Loader/Autoloader.php';
$loader = Zend_Loader_Autoloader::getInstance();


$include_time_end = microtime(true);
$new_time_start = microtime(true);

// $input = new ANTLRFileStream(dirname(__FILE__).DIRECTORY_SEPARATOR."input");
$input = new ANTLRStringStream("Individual: Mary Types: Person");
// echo "query = " . file_get_contents(dirname(__FILE__).DIRECTORY_SEPARATOR."input") . "\noutput = \n";
$time_lex = microtime(true);
$lexer = new StrippedMosNewLexer($input);
$tokens = new CommonTokenStream($lexer);
$time_lex_end = microtime(true);
$time_parse=microtime(true);
$parser = new StrippedMosNewParser($tokens);
$q = $parser->individualFrame();
// var_dump($q);
echo ($q->toN3());
// var_dump ($q->toRdfArray());
$time_parse_end=microtime(true);
$time_end = microtime(true);
$time = $time_end - $time_start;

echo "\nincluding files time : " . ($include_time_end - $time_start) .PHP_EOL;
echo "lex time : " . ($time_lex_end - $time_lex) .PHP_EOL;
echo "parse time : " . ($time_parse_end - $time_parse) .PHP_EOL;

// http://convert.test.talis.com/
// http://n2.talis.com/wiki/RDF_JSON_Brainstorming
// http://n2.talis.com/wiki/RDF_PHP_Specification
// http://n2.talis.com/wiki/RDF_JSON_Specification