grammar StrippedMosNew;

options {
  language  = Php;
  backtrack = true;
  //memoize   = true;
}

import StrippedMosTokenizerNew;

parse returns [$value]
  : l=description {\$value = $l.value;}
  ;

description returns [$value]
@init{
\$value = new ObjectUnionOf();
}
  :
  c1=conjunction {\$value->addElement($c1.value);}
        (OR_LABEL c2=conjunction {\$value->addElement($c2.value);})*
  ;

conjunction returns [$value]
@init{\$value = new ObjectIntersectionOf();}
  :
  (c=classIRI THAT_LABEL {\$value->addElement($c.value);})? p1=primary {
            \$value->addElement($p1.value);}
    (AND_LABEL p2=primary {\$value->addElement($p2.value);})*
  ;

primary returns [$value]
  :
  (n=NOT_LABEL)? (v=restriction | v=atomic) {
            if(isset(\$n)) {\$value = new ObjectComplementOf($v.value);}
            else {\$value = $v.value;}
  }
  ;

iri returns [$value]
@after {
\$value = new Iri($v.text);
}
  :
  v=FULL_IRI
  | v=ABBREVIATED_IRI
  | v=SIMPLE_IRI
  ;

objectPropertyExpression returns [$value]
@after{\$value = $v.value;}
  :
  v=objectPropertyIRI
  | v=inverseObjectProperty
  ;

restriction returns [$value]
  :
  o=objectPropertyExpression
    ((SOME_LABEL p=primary {\$value = new ObjectSomeValuesFrom($o.value, $p.value);})
    | (ONLY_LABEL p=primary {\$value = new ObjectAllValuesFrom($o.value, $p.value);})
    | (VALUE_LABEL i=individual {\$value = new ObjectHasValue($o.value, $i.value);})
    | (SELF_LABEL {\$value = new ObjectHasSelf($o.value);})
    | (MIN_LABEL nni=nonNegativeInteger p=primary? {\$value = new ObjectMinCardinality($o.value, $nni.value, isset(\$p)?$p.value:null);})
    | (MAX_LABEL nni=nonNegativeInteger p=primary? {\$value = new ObjectMaxCardinality($o.value, $nni.value, isset(\$p)?$p.value:null);})
    | (EXACTLY_LABEL nni=nonNegativeInteger p=primary? {\$value = new ObjectExactCardinality($o.value, $nni.value, isset(\$p)?$p.value:null);})
  )
  | dp=dataPropertyExpression(
    (SOME_LABEL d=dataRange {\$value = new DataSomeValuesFrom($dp.value, $d.value);})
  | (ONLY_LABEL d=dataRange {\$value = new DataAllValuesFrom($dp.value, $d.value);})
  | (VALUE_LABEL l=literal{\$value = new DataHasValue($dp.value, $l.value);})
  | (MIN_LABEL nni=nonNegativeInteger d=dataRange? {\$value = new DataMinCardinality($dp.value, $nni.value, isset(\$d)?$d.value:null);})
  | (MAX_LABEL nni=nonNegativeInteger d=dataRange? {\$value = new DataMaxCardinality($dp.value, $nni.value, isset(\$d)?$d.value:null);})
  | (EXACTLY_LABEL nni=nonNegativeInteger d=dataRange? {\$value = new DataExactCardinality($dp.value, $nni.value, isset(\$d)?$d.value:null);})
        )
  ;

atomic returns [$value]
  :
  classIRI {\$value = new OwlClass($classIRI.value);}
  | OPEN_CURLY_BRACE individualList CLOSE_CURLY_BRACE {\$value = new ObjectOneOf($individualList.value);}
  | OPEN_BRACE description CLOSE_BRACE {\$value = $description.value;}
  ;

classIRI returns [$value]
  :
  iri {$value = $iri.value;}
  ;

individualList returns [$value]
  :
  i=individual {\$value = new IndividualList($i.value);}
    (COMMA i1=individual {\$value->addElement($i1.value);})*
  ;

individual returns [$value]
  :
  i=individualIRI {\$value = new NamedIndividual($i.value);}
  | NODE_ID {\$value = new AnonymousIndividual($NODE_ID.text);}
  ;

nonNegativeInteger returns [$value]
  :
  DIGITS {\$value = $DIGITS.text;}
  ;

dataPrimary returns [$value]
  :
  (n=NOT_LABEL)? dataAtomic {
            \$value = (isset(\$n))? new DataComplementOf($dataAtomic.value) : $dataAtomic.value;}
  ;

dataPropertyExpression returns [$value]
  :
  d=dataPropertyIRI {\$value = $d.value;}
  ;

dataAtomic returns [$value]
  :
  (dataType {\$value = $dataType.value;})
  | (OPEN_CURLY_BRACE literalList CLOSE_CURLY_BRACE {\$value = new DataOneOf($literalList.value);})
  | (dataTypeRestriction {\$value = $dataTypeRestriction.value;})
  | (OPEN_BRACE dataRange CLOSE_BRACE {\$value = $dataRange.value;})
  ;

literalList returns [$value]
  :
  l1=literal {\$value = new LiteralList($l1.value);}
  (COMMA l2=literal {\$value->addElement($l2.value);})*
  ;

dataType returns [$value]
  :
  datatypeIRI {\$value = $datatypeIRI.value;}
  | v=INTEGER_LABEL {\$value = $v.text;} 
  | v=DECIMAL_LABEL {\$value = $v.text;}
  | v=FLOAT_LABEL {\$value = $v.text;}
  | v=STRING_LABEL {\$value = $v.text;}
  ;

literal returns [$value]
@after{\$value = $v.value;}
  :
  v=typedLiteral | v=stringLiteralNoLanguage | v=stringLiteralWithLanguage | v=integerLiteral | v=decimalLiteral | v=floatingPointLiteral
  ;

stringLiteralNoLanguage returns [$value]
  :
  QUOTED_STRING {
            \$value = new StringLiteral($QUOTED_STRING.text);
        }
  ;

stringLiteralWithLanguage returns [$value]
  :
  QUOTED_STRING LANGUAGE_TAG {\$value = new StringLiteral ($QUOTED_STRING.text, $LANGUAGE_TAG.text);}
  ;

lexicalValue returns [$value]
  :
  QUOTED_STRING {\$value = $QUOTED_STRING.text;}
  ;

typedLiteral returns [$value]
  :
  lexicalValue REFERENCE dataType {\$value = new TypedLiteral($lexicalValue.value, $dataType.value);}
  ;

restrictionValue returns [$value]
  :
  literal {\$value = $literal.value;}
  ;

inverseObjectProperty returns [$value]
  :
  INVERSE_LABEL objectPropertyIRI {
            \$value = new ObjectPropertyExpression($objectPropertyIRI.value, true);}
  ;

decimalLiteral returns [$value]
  :
  DLITERAL_HELPER {\$value = new DecimalLiteral($DLITERAL_HELPER.text);}
  ;

integerLiteral returns [$value]
  : (i=ILITERAL_HELPER | i=DIGITS) {\$value = new IntegerLiteral($i.text);}
  ;

floatingPointLiteral returns [$value]
  :
  FPLITERAL_HELPER {\$value = new FloatingPointLiteral($FPLITERAL_HELPER.text);}
  ;

objectProperty returns [$value]
  :
  objectPropertyIRI {\$value = new ObjectPropertyExpression($objectPropertyIRI.value);}
  ;

dataProperty returns [$value]
  :
  dataPropertyIRI {\$value = new DataProperty($dataPropertyIRI.value);}
  ;

dataPropertyIRI returns [$value]
  :
  iri {\$value = $iri.value;}
  ;

datatypeIRI returns [$value]
  :
  iri {\$value = $iri.value;}
  ;

objectPropertyIRI returns [$value]
  :
  iri {\$value = $iri.value;}
  ;

dataTypeRestriction returns [$value]
  :
  dataType {\$value = new DatatypeRestriction($dataType.value);} OPEN_SQUARE_BRACE
        ( f=facet r=restrictionValue {\$value -> addRestriction($f.value, $r.value);})+
  CLOSE_SQUARE_BRACE
  ;

individualIRI returns [$value]
  :
  iri {\$value = $iri.value;}
  ;

datatypePropertyIRI returns [$value]
  :
  iri {\$value = $iri.value;}
  ;

facet returns [$value]
@after{\$value = $v.text;}
  :
  v=LENGTH_LABEL | v=MIN_LENGTH_LABEL | v=MAX_LENGTH_LABEL | v=PATTERN_LABEL | v=LANG_PATTERN_LABEL | v=LESS_EQUAL | v=LESS | v=GREATER_EQUAL | v=GREATER
  ;

dataRange returns [$value]
  :
  d1=dataConjunction {\$value = new DataUnionOf($d1.value);} 
        (OR_LABEL d2=dataConjunction {\$value->addElement($d2.value);})*
  ;

dataConjunction returns [$value]
  :
  d1=dataPrimary {\$value = new DataIntersectionOf($d1.value);}
            (AND_LABEL d2=dataPrimary {\$value->addElement($d2.value);})*
  ;

///////
// full mos

annotationAnnotatedList returns [$value]
	:	(annotations)? annotation (COMMA (annotations)? annotation)*
	;

annotation returns [$value]
	:	ap=annotationPropertyIRI at=annotationTarget {\$value = new Annotation($ap.value,$at.value);}
	;

annotationTarget returns [$value]
	:	NODE_ID {\$value = $NODE_ID.text;}
	|	iri {\$value = $iri.value;}
	|	literal {\$value = $literal.value;}
	;
annotations returns [$value]
	: (ANNOTATIONS_LABEL a=annotationAnnotatedList {\$value = $a.value;})?
	;

descriptionAnnotatedList returns [$value]
	:	annotations? description {\$value = $description.value;} (COMMA descriptionAnnotatedList)*
	;

description2List returns [$value]
	:	d=description COMMA dl=descriptionList {\$value = new OwlList($d.value); \$value->addAllElements($dl.value);}
	;

descriptionList returns [$value]
	:	d1=description {\$value = new OwlList($d1.value);} (COMMA d2=description {\$value->addElement($d2.value);})*
	;

classFrame returns [$value]
	:	CLASS_LABEL c=classIRI
	(	ANNOTATIONS_LABEL annotationAnnotatedList
		|	SUBCLASS_OF_LABEL s=descriptionAnnotatedList {\$value = new SubClassOf($c.value, $s.value);}
		|	EQUIVALENT_TO_LABEL e=descriptionAnnotatedList {\$value = new EquivalentClasses($c.value, $e.value);}
		|	DISJOINT_WITH_LABEL d=descriptionAnnotatedList
		|	DISJOINT_UNION_OF_LABEL annotations description2List
	)*
	//TODO owl2 primer error?
	(	HAS_KEY_LABEL annotations?
			((objectPropertyExpression)=>objectPropertyExpression | dataPropertyExpression)+)?
	;

objectPropertyFrame
	:	OBJECT_PROPERTY_LABEL objectPropertyIRI
	(	ANNOTATIONS_LABEL annotationAnnotatedList
		|	RANGE_LABEL descriptionAnnotatedList
		|	CHARACTERISTICS_LABEL objectPropertyCharacteristicAnnotatedList
		|	SUB_PROPERTY_OF_LABEL objectPropertyExpressionAnnotatedList
		|	EQUIVALENT_TO_LABEL objectPropertyExpressionAnnotatedList
		|	DISJOINT_WITH_LABEL objectPropertyExpressionAnnotatedList
		|	INVERSE_OF_LABEL objectPropertyExpressionAnnotatedList
		|	SUB_PROPERTY_CHAIN_LABEL annotations objectPropertyExpression (O_LABEL objectPropertyExpression)+
		)*
	;

objectPropertyCharacteristicAnnotatedList
	:	annotations? OBJECT_PROPERTY_CHARACTERISTIC (COMMA objectPropertyCharacteristicAnnotatedList)*
	;

objectPropertyExpressionAnnotatedList
	:	annotations? objectPropertyExpression (COMMA objectPropertyExpressionAnnotatedList)*
	;

dataPropertyFrame
    : DATA_PROPERTY_LABEL  dataPropertyIRI
    (	ANNOTATIONS_LABEL annotationAnnotatedList
    |	DOMAIN_LABEL  descriptionAnnotatedList
    |	RANGE_LABEL  dataRangeAnnotatedList
    |	CHARACTERISTICS_LABEL  annotations FUNCTIONAL_LABEL
    |	SUB_PROPERTY_OF_LABEL  dataPropertyExpressionAnnotatedList
    |	EQUIVALENT_TO_LABEL  dataPropertyExpressionAnnotatedList
    |	DISJOINT_WITH_LABEL  dataPropertyExpressionAnnotatedList
    )*
    ;

dataRangeAnnotatedList
	:	annotations? dataRange (COMMA dataRangeAnnotatedList)*
	;

dataPropertyExpressionAnnotatedList
	:	annotations? dataPropertyExpression (COMMA dataPropertyExpressionAnnotatedList)*
	;

annotationPropertyFrame
	:	ANNOTATION_PROPERTY_LABEL annotationPropertyIRI
	(	ANNOTATIONS_LABEL  annotationAnnotatedList )*
	|	DOMAIN_LABEL  iriAnnotatedList
	|	RANGE_LABEL  iriAnnotatedList
	|	SUB_PROPERTY_OF_LABEL annotationPropertyIRIAnnotatedList
	;
	
iriAnnotatedList
	:	annotations? iri (COMMA iriAnnotatedList)*
	;

annotationPropertyIRI returns [$value]
	:	iri {\$value = $iri.value;}
	;

annotationPropertyIRIAnnotatedList
	:	annotations? annotationPropertyIRI (COMMA annotationPropertyIRIAnnotatedList)*
	;

individualFrame returns [$value]
	:	INDIVIDUAL_LABEL  i=individual
	(	ANNOTATIONS_LABEL  a=annotationAnnotatedList {\$value = new AnnotationAssertion($i.value, $a.value);}
		|	TYPES_LABEL  d=descriptionAnnotatedList {\$value = new ClassAssertion($i.value, $d.value);}
		|	FACTS_LABEL  f=factAnnotatedList {\$value = new ObjectPropertyAssertion($i.value, $f.value);}
		|	SAME_AS_LABEL  ial=individualAnnotatedList {\$value = new SameIndividual($i.value, $ial.value);}
		|	DIFFERENET_FROM_LABEL ial1=individualAnnotatedList {\$value = new DifferentIndividuals($i.value, $ial.value);}
	)*
	;


factAnnotatedList returns [$value]
	:	annotations? fact (COMMA factAnnotatedList)*
	;

individualAnnotatedList returns [$value]
	:	annotations? individual (COMMA individualAnnotatedList)*
	;

fact	:	NOT_LABEL? (objectPropertyFact | dataPropertyFact);

objectPropertyFact
	:	objectPropertyIRI individual
	;

dataPropertyFact
	:	dataPropertyIRI literal
	;

datatypeFrame
	:	DATATYPE_LABEL  dataType
		(ANNOTATIONS_LABEL  annotationAnnotatedList)*
		(EQUIVALENT_TO_LABEL  annotations dataRange)?
		(ANNOTATIONS_LABEL  annotationAnnotatedList)*
	;

misc returns [$value]
	:	EQUIVALENT_CLASSES_LABEL  annotations description2List
	|	DISJOINT_CLASSES_LABEL  annotations description2List {\$value = new DisjointClasses($annotations.value, $description2List.value);}
	|	EQUIVALENT_PROPERTIES_LABEL  annotations (objectProperty2List | dataProperty2List)
	|	DISJOINT_PROPERTIES_LABEL  annotations (objectProperty2List | dataProperty2List)
	|	SAME_INDIVIDUAL_LABEL  annotations individual2List
	|	DIFFERENT_INDIVIDUALS_LABEL  annotations individual2List
	;
	
individual2List
	:	individual COMMA individualList
	;

dataProperty2List
	:	dataProperty COMMA dataPropertyList
	;
	
dataPropertyList
	:	dataProperty (COMMA dataProperty)*
	;

objectProperty2List
	:	objectProperty COMMA objectPropertyList
	;

objectPropertyList
	:	objectProperty (COMMA objectProperty)*
	;

frame
	: datatypeFrame
	| classFrame
	| objectPropertyFrame
	| dataPropertyFrame
	| annotationPropertyFrame
	| individualFrame
	| misc
	;

entity
	: DATATYPE_LABEL OPEN_BRACE dataType CLOSE_BRACE
	| CLASS_LABEL OPEN_BRACE classIRI CLOSE_BRACE
	| OBJECT_PROPERTY_LABEL OPEN_BRACE objectPropertyIRI CLOSE_BRACE
	| DATA_PROPERTY_LABEL OPEN_BRACE datatypePropertyIRI CLOSE_BRACE
	| ANNOTATION_PROPERTY_LABEL OPEN_BRACE annotationPropertyIRI CLOSE_BRACE
	| NAMED_INDIVIDUAL_LABEL OPEN_BRACE individualIRI CLOSE_BRACE
	;

ontology
	: ONTOLOGY_LABEL (ontologyIri (versionIri)?)? imports* annotations* frame*
	;

ontologyIri
	: iri
	;

versionIri
	:	iri
	;

imports	:	IMPORT_LABEL iri;




ITFUCKINDOESNTWORK : 'ggggggggr!!!';
