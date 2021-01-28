module namespace voice = 'http://www.univie.ac.at/voice/ns/1.0';

import module namespace admin = "http://basex.org/modules/admin"; (: for logging :)
import module namespace openapi="https://lab.sub.uni-goettingen.de/restxqopenapi" at "../openapi4restxq/content/openapi.xqm";

declare namespace exist = "http://exist.sourceforge.net/NS/exist"; (: for compatibility with xsl :)
declare namespace tei = 'http://www.tei-c.org/ns/1.0';
declare namespace cq = "http://www.univie.ac.at/voice/corpusquery";

declare variable $voice:log := true();
declare variable $voice:collection := 'VOICEmerged';
declare variable $voice:apiBasePath := "/VOICE_CLARIAH";
declare variable $voice:corpusHeader as document-node() := doc('VOICEheader/_corpus-header.xml_');
declare variable $voice:audioDesc as document-node() := fn:parse-xml(file:read-text(file:base-dir()||'/audio/voiceAudioDesc.xml'));
declare variable $voice:audioBasePath := "https://voice.acdh.oeaw.ac.at/sound";
declare variable $voice:noskeRunCgi := "https://voice-noske.acdh-dev.oeaw.ac.at/bonito/run.cgi";
declare variable $voice:speakers := json:parse(serialize(map:merge(for $i in collection($voice:collection)//tei:listPerson//*[@sameAs]
group by $sa := $i/@sameAs/data()
let $c := count($i)
order by $c descending
return map {substring($sa, 2):
map{"age": $i[1]/tei:age/text(),
    "sex": $i[1]/tei:sex/text(),
    "occupation": $i[1]/tei:occupation/text(),
    "L1": array {$i[1]/tei:langKnowledge/*[@level="L1"]/@tag/data()},
    "refs" : map:merge(
      for $r in $i/@xml:id
      return map {substring-before($r/data(), '_'): map{
        "role": $r/../@role/data(),
        "tag": substring-after($r/data(), '_')
      }}
    )}
  }
), map {"method": "json"}));

declare %private function voice:path($textid as xs:string, $view as xs:string){
    let $b :=
        if ($textid = "teiCorpus")
        then $voice:apiBasePath||"/corpus"
        else $voice:apiBasePath||"/speechEvent/"||$textid
    return switch ($view)
        case "tei"      return $b
        case "audio"    return if ($voice:audioDesc//cq:SoundFile[@corresponds=concat('#', $textid)]) then $voice:audioBasePath||"/"||$textid||".mp3" else ()
        default return $b||"/"||$view
};

declare
  %rest:path("/VOICE_CLARIAH/corpus/tree")
  %rest:GET
  %rest:produces("application/json")
  %rest:produces("application/xml")
  %rest:produces("text/html")
  %rest:query-param("method", "{$method}", "json")
function voice:get-tree-as-xml($method as xs:string?) {
    let $ret := <json type="object">
		<label>VOICE</label>
    <title>{$voice:corpusHeader//tei:titleStmt/tei:title/text()}</title>
    <principal>{$voice:corpusHeader//tei:titleStmt/tei:principal/text()}</principal>
    <researchers type="array">{$voice:corpusHeader//tei:editionStmt/tei:respStmt/tei:name!<_>{./text()}</_>}</researchers>
    <funder>{normalize-space($voice:corpusHeader//tei:titleStmt/tei:funder/text())}</funder>
    <edition>{string-join($voice:corpusHeader//tei:editionStmt/tei:edition//text(), ' ')}</edition>
    <extent>{$voice:corpusHeader//tei:extent/text()}</extent>
    <publisher type="array">{tokenize($voice:corpusHeader//tei:publicationStmt/tei:publisher/text(), ', ')!<_>{.}</_>}</publisher>
    <distributor>{$voice:corpusHeader//tei:publicationStmt/tei:distributor/text()}</distributor>
    <source__description>{serialize($voice:corpusHeader//tei:sourceDesc/*, map {"method": "xml", "indent": "no"})}</source__description>
    <availability>{serialize($voice:corpusHeader//tei:publicationStmt/tei:availability/*, map {"method": "xml", "indent": "no"})}</availability>
    <refs type="object">
       <teiHeader>{voice:path("teiCorpus", "header")}</teiHeader>
    </refs>
		<domains type="array">{
			for $t in collection($voice:collection)//tei:TEI
	        let $id := $t/@xml:id
	        let $dom := substring($id, 1, 2)
       		group by $dom 
        	return 
        	<_ type="object">
		    	<label>{$dom}</label>
				<speechEvents type="array">{
	    	        for $i in $id
		            let $header := root($i)//tei:teiHeader 
		            let $title := $header//tei:titleStmt/tei:title
		           
		            let $speakers_no := $header//tei:personGrp[@role = 'speakers']/xs:integer(@size)
		            let $speakers_bucket := 
		                  switch (true())
		                      case $speakers_no le 3 return "2–3"
		                      case $speakers_no ge 4 and $speakers_no le 6 return "4–6"
		                      case $speakers_no ge 7 and $speakers_no le 10 return "7–10"
		                      case $speakers_no ge 11 and $speakers_no le 14 return "11–14"
		                      default return "15 and more"
		                      
		            let $interactants_no := $header//tei:personGrp[@role = 'interactants']/xs:integer(@size)
		            
		            let $interactants_bucket :=
		                  switch (true())
		                      case $interactants_no le 3 return "2–3"
		                      case $interactants_no ge 4 and $interactants_no le 6 return "4–6"
		                      case $interactants_no ge 7 and $interactants_no le 10 return "7–10"
		                      case $interactants_no ge 11 and $interactants_no le 14 return "11–14"
		                      default return "15 and more"
		            
		            (: CHANGEME: This should be inside of extent :)
		            let $no_of_words := $header//tei:note[starts-with(.,'Words')]/xs:integer(normalize-space(substring-after(.,'Words:')))
                let $no_of_words_bucket :=
                      switch(true())
                          case xs:integer($no_of_words) le 2999 return "0–2999"
                          case xs:integer($no_of_words) ge 3000 and xs:integer($no_of_words) le 5999 return "3000–5999"
                          case xs:integer($no_of_words) ge 6000 and xs:integer($no_of_words) le 9999 return "6000–9999"
                          case xs:integer($no_of_words) ge 10000 and xs:integer($no_of_words) le 14999 return "10000–14999"
                          default return "15000+"


		            let $dur := $header//tei:recording/xs:duration(@dur),
		                $dur_in_seconds := seconds-from-duration($dur)+minutes-from-duration($dur)*60+hours-from-duration($dur)*1200

                let $dur_bucket :=
                      switch(true())
                        case $dur_in_seconds le 60*29 return "0–29min"
                        case $dur_in_seconds gt 60*29 and $dur_in_seconds ge 60*59 return "30–59min"
                        case $dur_in_seconds gt 60*30 and $dur_in_seconds ge 60*119 return "1h–1h59"
                        default return "2h+"

		            let $order := replace($i, '\p{L}','')
		            let $speech_event_type := substring-before(substring-after($i, $dom),$order)
		            
		            let $audioLocation := voice:path($i, "audio")
		            
		            

                let $relation := $header//tei:relation

		            (: CHECKME probably there are no tracks at all :)
		            (:let $tracks := 
                        for $sf in $sfs
                        let $filename := 
                            if(count($sfs) > 1) 
                            then concat($i, "_", $sf/@num, ".mp3") 
                            else concat($i, ".mp3")
                        return map {"num" : xs:integer($sf/@num), "path" : $voice:audioBasePath||"/"||$filename}:)
                        
		            order by $speech_event_type, xs:integer($order) ascending
		            (:where $interactants_no ne 0:)
	    	        return
						<_ type="object">
							<id>{data($i)}</id>
							<title>{normalize-space($title)}</title>
							<domain>{$dom}</domain>
							<spet>{$speech_event_type}</spet>
							<refs type="object">
							     <audio type="{if ($audioLocation != '') then 'string' else 'null'}">{$audioLocation}</audio>
							     <TEI>{voice:path($i, "tei")}</TEI>
							     <teiHeader>{voice:path($i, "header")}</teiHeader>
							</refs>
							<audioAvailable type="boolean">{$audioLocation != ''}</audioAvailable>
							<!--type="array">{
							     for $t in $tracks
							     return 
							         <_ type="object">
							             <num type="number">{$t('num')}</num>
							             <location>{$t('path')}</location>
							         </_>
							}</tracks>-->
							<words type="number">{$no_of_words}</words>
              <wordsBucket type="string">{$no_of_words_bucket}</wordsBucket>
							<duration type="number">{$dur_in_seconds}</duration>
              <durationBucket type="string">{$dur_bucket}</durationBucket>
							<speakers type="number">{$speakers_no}</speakers>
							<speakersBucket>{$speakers_bucket}</speakersBucket>
              <speakers type="object">{$voice:speakers/*/*[refs/*/local-name() = data($i)]}</speakers>
              <speakersL1 type="array">{distinct-values($voice:speakers/*/*[refs/*/local-name() = data($i)]/L1/_/substring-after(.,'-'))[. != '']!<_>{.}</_>}</speakersL1>
							<interactants type="number">{$interactants_no}</interactants>
							<interactantsBucket>{$interactants_bucket}</interactantsBucket>
              <relationPower type="string">{$relation[@type="power"]/data(@name)}</relationPower>
              <relationAcquaintedness type="string">{$relation[@type="acquaintedness"]/data(@name)}</relationAcquaintedness>
						</_>
				}</speechEvents>
        	</_>
	    }</domains>
   </json>
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("/VOICE_CLARIAH/corpus/header")
  %rest:GET
  %rest:produces("application/xml")
  %rest:produces("application/json")
  %rest:query-param("method", "{$method}", "xml")
function voice:getHeader($method as xs:string?) {
    let $ret := switch($method)
      case 'json' return json:serialize($voice:corpusHeader)
      default return $voice:corpusHeader   
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/{$id}")
  %rest:GET
  %rest:query-param("method", "{$method}", "html")
function voice:get-doc($id, $method as xs:string?) {
  let $ret := switch ($method)
  case "html" return (
    <link rel="stylesheet" type="text/css" href="voice_online.css"/>,
    <link rel="stylesheet" type="text/css" href="view_transcript.css"/>,
    parse-xml-fragment(xslt:transform-text(doc($voice:collection||"/"||$id||".xml"), doc(file:parent(static-base-uri())||"/styles/voice.xsl")))
  )
  default return doc($voice:collection||"/"||$id||".xml")
   return (<rest:response> 
    <output:serialization-parameters>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret)
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/voice_online.css")
  %rest:header-param("If-None-Match", "{$if-none-match}")
  %rest:GET
function voice:get-voice-online-css($if-none-match as xs:string?) {
  voice:return-content(file:read-binary(file:parent(static-base-uri())||'/voice_online.css'), web:content-type(file:parent(static-base-uri())||'/voice_online.css'), $if-none-match)
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/view_transcript.css")
  %rest:header-param("If-None-Match", "{$if-none-match}")
  %rest:GET
function voice:get-view-transcript-css($if-none-match as xs:string?) {
  voice:return-content(file:read-binary(file:parent(static-base-uri())||'/view_transcript.css'), web:content-type(file:parent(static-base-uri())||'/view_transcript.css'), $if-none-match)
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/{$id}/header")
  %rest:GET
  %output:method("xml")
function voice:get-header($id) {
    doc($voice:collection||"/"||$id||".xml")//tei:teiHeader
};

declare
  %rest:path("/VOICE_CLARIAH/speechEvent/search")
  %rest:GET
  %rest:query-param("q", "{$q}")
  %rest:query-param("from", "{$from}", "1")
  %rest:query-param("pagesize", "{$pagesize}", "20")
  %rest:query-param("method", "{$method}", "html")
function voice:search($q as xs:string?, $from as xs:integer, $pagesize as xs:integer, $method as xs:string?) {
  let $log := voice:l($q),
      $response := http:send-request(
    <http:request method="GET"
     href='{$voice:noskeRunCgi}/first?corpname=voice&amp;queryselector=iqueryrow&amp;iquery={translate($q, ' ', '+')}&amp;attrs=wid&amp;kwicleftctx=0&amp;kwicrightctx=0&amp;pagesize=100000'/>
  ),
      $resultIDs := $response[2]//Lines/_/Kwic/_/str,
      $foundTags := map:merge((for $id at $i in $resultIDs
        let $foundTags := collection($voice:collection)//*[@xml:id = tokenize($id, ' ')]
        group by $uID := $foundTags/ancestor::*:u/@xml:id/data()
        return map{if (empty($uID)) then 'catch empty utterance ID' else $uID: $foundTags})), (: TODO where does this come from? search "be not":)
      $foundUtteranceIDs := subsequence(distinct-values($foundTags?*!ancestor::*:u/@xml:id), $from, $pagesize),
      $utterances := <_>{collection($voice:collection)//*[@xml:id = $foundUtteranceIDs]}</_>,
      $highlightedUtterances := <_>{for $u in $utterances/*
        let $highlightIDs := $foundTags($u/@xml:id)/@xml:id
        return $u update for $n in .//*[@xml:id = $highlightIDs] return replace node $n with <exist:match>{$n}</exist:match>}</_>,
      $ret := switch ($method)
        case "html" return (
          <link rel="stylesheet" type="text/css" href="voice_online.css"/>,
          <link rel="stylesheet" type="text/css" href="view_transcript.css"/>,
          parse-xml-fragment(xslt:transform-text($highlightedUtterances, doc(file:parent(static-base-uri())||"/styles/voice.xsl")))
        )
        case "basex" return $foundTags
        default return $highlightedUtterances
  return (<rest:response> 
    <output:serialization-parameters>
      <output:media-type value="{if ($method = ('xhtml', 'html')) then 'text/html'
                                 else if ($method='xml') then 'application/xml'
                                 else if ($method='json') then 'application/json' else 'text/plain'}"/>
      <output:method value='{$method}'/>
    </output:serialization-parameters>
   </rest:response>,
   $ret
   (: , if ($foundTags('xxx')) then (<error/>, $foundTags('xxx')) else () :)
   )
};

declare
    %rest:path('/VOICE_CLARIAH/openapi.json')
    %rest:produces('application/json')
    %output:media-type('application/json')
function voice:getOpenapiJSON() as item()+ {
  openapi:json(file:base-dir())
};

declare %private function voice:l($message as xs:string) as empty-sequence() {
  if ($voice:log) then admin:write-log($message, 'INFO') else ()
};

declare %private function voice:return-content($bin, $media-type as xs:string, $if-none-match as xs:string?) {
  let $hash := xs:string(xs:hexBinary(hash:md5($bin)))
      , $hashBrowser := if (empty($if-none-match)) then
        try {request:header('If-None-Match', '')} catch * {''} (: broken in 9.0.2 :)
        else $if-none-match
    return if ($hash = $hashBrowser) then
      voice:workaround_902(web:response-header(map{}, map{}, map{'status': 304, 'message': 'Not Modified'}))
    else (
      voice:workaround_902(web:response-header(map { 'media-type': $media-type,
                                'method': 'basex',
                                'binary': 'yes' }, 
                          map { 'X-UA-Compatible': 'IE=11'
                              , 'Cache-Control': 'max-age=3600,public'
                              , 'ETag': $hash })),
      $bin
    )
};

declare %private function voice:workaround_902($in as element(rest:response)) as element(rest:response) {
  if (db:system()//version = ('9.0.2'))
  then copy $out := $in
  modify (delete node $out/@message,
              delete node $out/@status,
              insert node $in/@message as first into $out/*:response,
              insert node $in/@status as first into $out/*:response )
  return parse-xml-fragment(serialize(<_ xmlns:rest="http://exquery.org/ns/restxq" xmlns:http="http://expath.org/ns/http-client" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization">{$out}</_>, map {'indent': 'no'}))/*/*
  else $in
};
