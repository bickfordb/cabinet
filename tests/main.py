import unittest

import tests.adb
import tests.bdb
import tests.fdb
import tests.hdb
import tests.tdb

def main():
    test_loader = unittest.TestLoader()
    suites = []
    for test_module in [tests.adb, tests.bdb, tests.fdb, tests.hdb, tests.tdb]:
        suites.append(test_loader.loadTestsFromModule(test_module))
    suite = unittest.TestSuite(suites)
    test_runner = unittest.TextTestRunner().run(suite)

if __name__ == '__main__':
    main()
