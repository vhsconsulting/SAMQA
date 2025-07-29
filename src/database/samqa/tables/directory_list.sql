create global temporary table samqa.directory_list (
    file_id      number,
    filename     varchar2(255 byte),
    lastmodified date
) on commit preserve rows;


-- sqlcl_snapshot {"hash":"c99bd480a6f41fdaa3abba348917b8dca5168d93","type":"TABLE","name":"DIRECTORY_LIST","schemaName":"SAMQA","sxml":"\n  <TABLE xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <GLOBAL_TEMPORARY></GLOBAL_TEMPORARY>\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>DIRECTORY_LIST</NAME>\n   <RELATIONAL_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>FILE_ID</NAME>\n            <DATATYPE>NUMBER</DATATYPE>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>FILENAME</NAME>\n            <DATATYPE>VARCHAR2</DATATYPE>\n            <LENGTH>255</LENGTH>\n            <COLLATE_NAME>USING_NLS_COMP</COLLATE_NAME>\n         </COL_LIST_ITEM>\n         <COL_LIST_ITEM>\n            <NAME>LASTMODIFIED</NAME>\n            <DATATYPE>DATE</DATATYPE>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n      <DEFAULT_COLLATION>USING_NLS_COMP</DEFAULT_COLLATION>\n      <ON_COMMIT>PRESERVE</ON_COMMIT>\n   </RELATIONAL_TABLE>\n</TABLE>"}