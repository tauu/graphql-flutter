import 'package:gql_exec/gql_exec.dart';
import 'package:gql_link/gql_link.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:graphql/client.dart';
import 'package:gql/language.dart';

import './helpers.dart';

class MockLink extends Mock implements Link {}

void main() {
  const String readRepositories = r'''
  query ReadRepositories($nRepositories: Int!) {
    viewer {
      repositories(last: $nRepositories) {
        nodes {
          __typename
          id
          name
          viewerHasStarred
        }
      }
    }
  }
''';

  const String addStar = r'''
  mutation AddStar($starrableId: ID!) {
    action: addStar(input: {starrableId: $starrableId}) {
      starrable {
        viewerHasStarred
      }
    }
  }
''';

  MockLink link;
  GraphQLClient graphQLClientClient;

  group('simple json', () {
    setUp(() {
      link = MockLink();

      graphQLClientClient = GraphQLClient(
        cache: getTestCache(),
        link: link,
      );
    });

    group('query', () {
      test('successful response', () async {
        final WatchQueryOptions _options = WatchQueryOptions(
          documentNode: parseString(readRepositories),
          variables: <String, dynamic>{
            'nRepositories': 42,
          },
        );

        when(
          link.request(any),
        ).thenAnswer(
          (_) => Stream.fromIterable(
            [
              Response(
                data: <String, dynamic>{
                  'viewer': {
                    'repositories': {
                      'nodes': [
                        {
                          '__typename': 'Repository',
                          'id': 'MDEwOlJlcG9zaXRvcnkyNDgzOTQ3NA==',
                          'name': 'pq',
                          'viewerHasStarred': false,
                        },
                        {
                          '__typename': 'Repository',
                          'id': 'MDEwOlJlcG9zaXRvcnkzMjkyNDQ0Mw==',
                          'name': 'go-evercookie',
                          'viewerHasStarred': false,
                        },
                        {
                          '__typename': 'Repository',
                          'id': 'MDEwOlJlcG9zaXRvcnkzNTA0NjgyNA==',
                          'name': 'watchbot',
                          'viewerHasStarred': false,
                        },
                      ],
                    },
                  },
                },
              ),
            ],
          ),
        );

        final QueryResult r = await graphQLClientClient.query(_options);

        verify(
          link.request(
            Request(
              operation: Operation(
                document: parseString(readRepositories),
                operationName: 'ReadRepositories',
              ),
              variables: <String, dynamic>{
                'nRepositories': 42,
              },
              context: Context(),
            ),
          ),
        );

        expect(r.exception, isNull);
        expect(r.data, isNotNull);
        final List<Map<String, dynamic>> nodes =
            (r.data['viewer']['repositories']['nodes'] as List<dynamic>)
                .cast<Map<String, dynamic>>();
        expect(nodes, hasLength(3));
        expect(nodes[0]['id'], 'MDEwOlJlcG9zaXRvcnkyNDgzOTQ3NA==');
        expect(nodes[1]['name'], 'go-evercookie');
        expect(nodes[2]['viewerHasStarred'], false);
        return;
      });

      test('failed query because of an exception with null string', () async {
        final e = Exception();

        when(
          link.request(any),
        ).thenAnswer(
          (_) => Stream.fromFuture(Future.error(e)),
        );

        final QueryResult r = await graphQLClientClient.query(
          WatchQueryOptions(
            documentNode: parseString(readRepositories),
          ),
        );

        expect(
          (r.exception.clientException as UnhandledFailureWrapper).failure,
          e,
        );

        return;
      });

      test('failed query because of an exception with empty string', () async {
        final e = Exception('');

        when(
          link.request(any),
        ).thenAnswer(
          (_) => Stream.fromFuture(Future.error(e)),
        );

        final QueryResult r = await graphQLClientClient.query(
          WatchQueryOptions(
            documentNode: parseString(readRepositories),
          ),
        );

        expect(
          (r.exception.clientException as UnhandledFailureWrapper).failure,
          e,
        );

        return;
      });
//    test('failed query because of because of error response', {});
//    test('failed query because of because of invalid response', () {
//      String responseBody =
//          '{\"message\":\"Bad credentials\",\"documentation_url\":\"https://developer.github.com/v4\"}';
//      int responseCode = 401;
//    });
//    test('partially success query with some errors', {});
    });
    group('mutation', () {
      test('successful mutation', () async {
        final MutationOptions _options = MutationOptions(
          documentNode: parseString(addStar),
        );

        when(
          link.request(any),
        ).thenAnswer(
          (_) => Stream.fromIterable(
            [
              Response(
                data: <String, dynamic>{
                  'action': {
                    'starrable': {
                      'viewerHasStarred': true,
                    },
                  },
                },
              ),
            ],
          ),
        );

        final QueryResult response = await graphQLClientClient.mutate(_options);

        verify(
          link.request(
            Request(
              operation: Operation(
                document: parseString(addStar),
                operationName: 'AddStar',
              ),
              variables: <String, dynamic>{},
              context: Context(),
            ),
          ),
        );

        expect(response.exception, isNull);
        expect(response.data, isNotNull);
        final bool viewerHasStarred =
            response.data['action']['starrable']['viewerHasStarred'] as bool;
        expect(viewerHasStarred, true);
      });
    });
  });
}
