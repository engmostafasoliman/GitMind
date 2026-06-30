import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/repo_summary_model.dart';

class RepoSummaryDb {
  Database? _db;

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = join(dir, 'repo_summaries.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE repo_summaries (
            repo_id TEXT PRIMARY KEY,
            summary_json TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<Map<String, RepoSummaryModel>> getAll() async {
    final db = await _database;
    final rows = await db.query('repo_summaries');
    return {
      for (final row in rows)
        row['repo_id'] as String: RepoSummaryModel.fromJson(
          jsonDecode(row['summary_json'] as String) as Map<String, dynamic>,
        ),
    };
  }

  Future<RepoSummaryModel?> get(String repoId) async {
    final db = await _database;
    final rows = await db.query(
      'repo_summaries',
      where: 'repo_id = ?',
      whereArgs: [repoId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return RepoSummaryModel.fromJson(
      jsonDecode(rows.first['summary_json'] as String) as Map<String, dynamic>,
    );
  }

  Future<void> save(String repoId, RepoSummaryModel summary) async {
    final db = await _database;
    await db.insert(
      'repo_summaries',
      {
        'repo_id': repoId,
        'summary_json': jsonEncode(summary.toJson()),
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteAll() async {
    final db = await _database;
    await db.delete('repo_summaries');
  }
}
