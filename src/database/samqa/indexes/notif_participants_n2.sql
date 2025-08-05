create index samqa.notif_participants_n2 on
    samqa.notif_participants (
        user_id
    );


-- sqlcl_snapshot {"hash":"03c37b330d02f1bc8c89514d8a695bfe0e636da5","type":"INDEX","name":"NOTIF_PARTICIPANTS_N2","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>NOTIF_PARTICIPANTS_N2</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>NOTIF_PARTICIPANTS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>USER_ID</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}