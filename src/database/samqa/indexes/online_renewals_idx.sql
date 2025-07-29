create index samqa.online_renewals_idx on
    samqa.online_renewals (
        creation_date
    );


-- sqlcl_snapshot {"hash":"340ceace3b277ccbcdd4110113a4563a6301f148","type":"INDEX","name":"ONLINE_RENEWALS_IDX","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ONLINE_RENEWALS_IDX</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ONLINE_RENEWALS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>CREATION_DATE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}