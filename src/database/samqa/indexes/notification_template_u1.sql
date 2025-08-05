create index samqa.notification_template_u1 on
    samqa.notification_template (
        template_name
    );


-- sqlcl_snapshot {"hash":"142b32e0bc97abbdd0e03a47434780091df0dd37","type":"INDEX","name":"NOTIFICATION_TEMPLATE_U1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>NOTIFICATION_TEMPLATE_U1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>NOTIFICATION_TEMPLATE</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>TEMPLATE_NAME</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}