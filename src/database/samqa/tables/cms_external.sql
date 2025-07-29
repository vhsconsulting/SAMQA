create table samqa.cms_external (
    cms_record varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory debit_card_dir access parameters (
        records delimited by newline
        fields terminated by '~' optionally enclosed by '"' notrim
    ) location ( debit_card_dir : 'PCOB.BA.MR.GHPTIN.RESP.D20250421.T20260226.TXT' )
) reject limit 10;


-- sqlcl_snapshot {"hash":"c69e2ce7dc178d7b28697ac03fd7c5dfb5baae9c","type":"TABLE","name":"CMS_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>CMS_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CMS_RECORD</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>3200</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>DEBIT_CARD_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited BY newline  fields terminated BY '~' optionally enclosed BY '\"' NOTRIM \n             </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <DIRECTORY>DEBIT_CARD_DIR</DIRECTORY>\n                  <NAME>PCOB.BA.MR.GHPTIN.RESP.D20250421.T20260226.TXT</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>10</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}