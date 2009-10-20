# Tokyo Cabinet: IDL Compliant Python Bindings

# Example

-- example.py 
    from cabinet import tdb

    users = tdb.TDB()
    users.open('./users.tct', users.OCREAT | users.OREADER | users.OWRITER)

    # Create a lexical btree index on gender:
    users.setindex('gender', users.ITLEXICAL)

    # Add some users
    print "add"
    users['someid'] = {'name': 'Brandon', 'gender': 'm'}
    users['someotherid'] = {'name': 'Joyce', 'gender': 'f'}

    print "list"
    print list(users) 
    # => ['someid', 'someotherid']

    assert users.get('nonexistentid') is None

    assert users['someid']['name'] == 'Brandon'

    assert users['someotherid']['gender'] == 'f'

    query = users.query()
    query.addcond('gender', query.QCSTREQ, 'm')
    print query.search() # => ['someid']
