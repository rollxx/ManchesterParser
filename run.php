<?php
ini_set('error_reporting', E_ALL | E_STRICT);
set_include_path(get_include_path() . PATH_SEPARATOR . dirname(__FILE__) .'/antlr-generated');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/Literal');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/Individual');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/Annotations');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/Assertion');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/Axiom');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/ClassAxiom');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/DataRange');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/ClassExpression');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/ObjectPropertyRestriction');
set_include_path(get_include_path(). PATH_SEPARATOR . '/Users/roll/WebideProjects/OWL/DataPropertyRestriction');
ini_set("memory_limit","24M");
$time_start = microtime(true);
require_once '/Users/roll/Documents/dropdocs/Dropbox/dropdocs/projects/tmp/svn/runtime/Php/antlr.php';
require_once 'src/StrippedMosNewLexer.php';
require_once 'src/StrippedMosNewParser.php';
require_once 'src/StrippedMosNew_StrippedMosTokenizerNew.php';
// require_once 'RdfPhp.php';
// require_once 'Iri.php';
// require_once 'OwlClass.php';


function __autoload($class_name) {
    require_once $class_name . '.php';
}

// require_once 'StrippedMosNewTokenizer.php';
$include_time_end = microtime(true);
$new_time_start = microtime(true);

	$input = new ANTLRFileStream(dirname(__FILE__).DIRECTORY_SEPARATOR."input");
	echo "query = " . file_get_contents(dirname(__FILE__).DIRECTORY_SEPARATOR."input") . "\noutput = \n";
	$time_lex = microtime(true);
	$lexer = new StrippedMosNewLexer($input);
	$tokens = new CommonTokenStream($lexer);
	$time_lex_end = microtime(true);
	// foreach ($tokens->getTokens() as $t) {
	// 		echo $t."\n";
	// }
	$time_parse=microtime(true);
	$parser = new StrippedMosNewParser($tokens);
	$q = $parser->restriction();
	// var_dump($q);
	// echo ($q);
	var_dump ($q->toRdfArray());
	$time_parse_end=microtime(true);
$time_end = microtime(true);
$time = $time_end - $time_start;

echo "\nincluding files time : " . ($include_time_end - $time_start) .PHP_EOL;
echo "lex time : " . ($time_lex_end - $time_lex) .PHP_EOL;
echo "parse time : " . ($time_parse_end - $time_parse) .PHP_EOL;
?>
