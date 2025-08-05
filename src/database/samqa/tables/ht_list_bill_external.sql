create table samqa.ht_list_bill_external (
    line_number varchar2(3200 byte)
)
organization external ( type oracle_loader
    default directory listbill_dir access parameters (
        records delimited by newline
            badfile '2019-01-23zpyio040.txt.bad'
            logfile '2019-01-23zpyio040.txt.log'
        fields terminated by ',' optionally enclosed by '"' lrtrim missing field values are null
    ) location ( '2019-01-23zpyio040.txt' )
) reject limit 1;


-- sqlcl_snapshot {"hash":"9011ebc89b44ad5ab7c65c5191e3c9efc65ae198","type":"TABLE","name":"HT_LIST_BILL_EXTERNAL","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>HT_LIST_BILL_EXTERNAL</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>LINE_NUMBER</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>3200</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <PHYSICAL_PROPERTIES>\n         <EXTERNAL_TABLE>\n            <ACCESS_DRIVER_TYPE>ORACLE_LOADER</ACCESS_DRIVER_TYPE>\n            <DEFAULT_DIRECTORY>LISTBILL_DIR</DEFAULT_DIRECTORY>\n            <ACCESS_PARAMETERS>records delimited BY newline\n                badfile '2019-01-23zpyio040.txt.bad' logfile '2019-01-23zpyio040.txt.log'\n                fields terminated BY ',' optionally enclosed BY '\"'\n              LRTRIM MISSING FIELD VALUES ARE NULL </ACCESS_PARAMETERS>\n            <LOCATION>\n               <LOCATION_ITEM>\n                  <NAME>2019-01-23zpyio040.txt</NAME>\n               </LOCATION_ITEM>\n            </LOCATION>\n            <REJECT_LIMIT>1</REJECT_LIMIT>\n         </EXTERNAL_TABLE>\n      </PHYSICAL_PROPERTIES>\n   </RELATIONAL_TABLE>\n</TABLE>"}