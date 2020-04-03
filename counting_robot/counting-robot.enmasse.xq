xquery version "3.0";

(:~
 : A starter script for counting values and phenomena in XML using XPath and XQuery.
 : This version of counting-robot.xq can be used to create one report per input 
 : file, which may be useful when a cross-collection query is too computationally
 : expensive for oXygen. The reports can then be merged with the functions in
 : count-sets-library.xql.
 :
 : @return tab-delimited text
 :
 : @author Ashley M. Clark, Northeastern University Women Writers Project
 : @see https://github.com/NEU-DSG/wwp-public-code-share/tree/master/counting_robot
 : @version 1.4
 :
 :  2020-04-03: v1.4. Made $sortByCount, $sortWithArticles, and $query into external
 :    variables.
 :  2019-09-04: v1.3. Added MIT license and an example of a custom function.
 :  2019-04-25: v1.2. Updated GitHub link.
 :  2018-12-20: Added link to GitHub.
 :  2018-08-01: v1.1. Added some nonsortable articles.
 :  2017-11-16: Created using counting-robot.xq v1.0.
 :
 : MIT License
 :
 : Copyright (c) 2019 Northeastern University Women Writers Project
 :
 : Permission is hereby granted, free of charge, to any person obtaining a copy
 : of this software and associated documentation files (the "Software"), to deal
 : in the Software without restriction, including without limitation the rights
 : to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 : copies of the Software, and to permit persons to whom the Software is
 : furnished to do so, subject to the following conditions:
 :
 : The above copyright notice and this permission notice shall be included in all
 : copies or substantial portions of the Software.
 :
 : THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 : IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 : FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 : AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 : LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 : OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 : SOFTWARE.
 :)

(:  NAMESPACES  :)
  declare default element namespace "http://www.wwp.northeastern.edu/ns/textbase";
  declare namespace tei="http://www.tei-c.org/ns/1.0";
  declare namespace wwp="http://www.wwp.northeastern.edu/ns/textbase";
  declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
(:  OPTIONS  :)
  declare option output:item-separator "";
  declare option output:method "text";
  
  (: This sets our scope to the input file. :)
  declare context item external;


(:  VARIABLES - SORTING  :)
  (: Change $sortByCount to false() in order to sort by result value. :)
  declare variable $sortByCount external := true();
  
  (: Change $sortWithArticles to true() in order to sort results with any 
    leading articles. This will not affect your results, just the order in 
    which they display. :)
  declare variable $sortWithArticles external := false();

(:  VARIABLES - QUERYING  :)
  
  (: Change this to your XPath query. (Or your XQuery!) :)
    (:  For example: $VARIABLE/XPATH                    :)
  declare variable $query external := //text//title/normalize-space(.);


(:  FUNCTIONS  :)
  (: Place any custom functions here! :)
  (: For example:
       declare function local:say-hello($name) {
         concat("Hello, ",$name,"!")
       };
  :)
  
  (:
   : HEY! LISTEN: The code below powers your report-making robot. For most 
   : queries, you won't need to change anything after this point. 
   :)

(: This function strips out leading articles from a string value for sorting. 
  It also lower-cases the string, since capital letters will have an effect on 
  sort order. :)
declare function local:get-sortable-string($str as xs:string) {
  replace(lower-case(normalize-space($str)), '^(the|an|a|la|le|de|del|el|lo|las|los) ','')
};

(:  THE COUNTING ROBOT  :)
let $distinctValues := distinct-values($query)
let $listOfCounts :=  for $value in $distinctValues
                      let $count := count($query[. eq $value])
                      let $sortVal := if ( not($sortWithArticles) and $value castable as xs:string ) then 
                                        local:get-sortable-string($value)
                                      else $value
                      order by
                        if ( $sortByCount ) then () else $sortVal,
                        $count descending, 
                        $sortVal
                      return 
                        (: Tab-delimited data within rows. :)
                        concat($count, '&#9;', $value)
return 
  (: Separate each row with a newline. :)
  string-join($listOfCounts,'&#13;')
