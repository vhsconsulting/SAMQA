create index samqa.ach_upload_staging_n6 on
    samqa.ach_upload_staging (
        ssn
    );


-- sqlcl_snapshot {"hash":"03062782099fc08bc61d8140dd10792bc3b986d7","type":"INDEX","name":"ACH_UPLOAD_STAGING_N6","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>ACH_UPLOAD_STAGING_N6</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>ACH_UPLOAD_STAGING</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>SSN</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}