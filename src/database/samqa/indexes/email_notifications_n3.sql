create index samqa.email_notifications_n3 on
    samqa.email_notifications (
        mail_status
    );


-- sqlcl_snapshot {"hash":"6d687a130bc1efdba9feb1c3efe703290f402b15","type":"INDEX","name":"EMAIL_NOTIFICATIONS_N3","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>EMAIL_NOTIFICATIONS_N3</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>EMAIL_NOTIFICATIONS</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>MAIL_STATUS</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}