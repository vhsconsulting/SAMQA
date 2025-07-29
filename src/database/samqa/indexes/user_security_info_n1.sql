create index samqa.user_security_info_n1 on
    samqa.user_security_info (
        pw_question1
    );


-- sqlcl_snapshot {"hash":"c9e86c6c6bbf1f348c469ee8a3f9c03534a90246","type":"INDEX","name":"USER_SECURITY_INFO_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>USER_SECURITY_INFO_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>USER_SECURITY_INFO</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>PW_QUESTION1</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}