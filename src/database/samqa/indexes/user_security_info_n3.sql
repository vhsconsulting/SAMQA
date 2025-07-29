create index samqa.user_security_info_n3 on
    samqa.user_security_info (
        pw_question3
    );


-- sqlcl_snapshot {"hash":"25513845b44605275ac88202da4a047a019288fd","type":"INDEX","name":"USER_SECURITY_INFO_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>USER_SECURITY_INFO_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>USER_SECURITY_INFO</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PW_QUESTION3</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}