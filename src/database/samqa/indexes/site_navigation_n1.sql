create index samqa.site_navigation_n1 on
    samqa.site_navigation (
        nav_code
    );


-- sqlcl_snapshot {"hash":"2d1b84652a6bc2ec1196ba9105bde6d4d6ad1926","type":"INDEX","name":"SITE_NAVIGATION_N1","schemaName":"SAMQA","sxml":"\n  <INDEX xmlns=\"http://xmlns.oracle.com/ku\" version=\"1.0\">\n   <SCHEMA>SAMQA</SCHEMA>\n   <NAME>SITE_NAVIGATION_N1</NAME>\n   <TABLE_INDEX>\n      <ON_TABLE>\n         <SCHEMA>SAMQA</SCHEMA>\n         <NAME>SITE_NAVIGATION</NAME>\n      </ON_TABLE>\n      <COL_LIST>\n         <COL_LIST_ITEM>\n            <NAME>NAV_CODE</NAME>\n         </COL_LIST_ITEM>\n      </COL_LIST>\n   </TABLE_INDEX>\n</INDEX>"}