import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_file/open_file.dart';

import '../../app/app_strings.dart';
import '../../providers/translation_provider.dart';
import 'widgets/translation_progress_indicator.dart';

/// Tarjima jarayoni progressini real-vaqtda ko'rsatuvchi va yakunda
/// faylni yuklab olish/ochish imkonini beruvchi ekran.
class TranslateScreen extends ConsumerStatefulWidget {
  const TranslateScreen({super.key});

  @override
  ConsumerState<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends ConsumerState<TranslateScreen> {
  bool _isDownloading = false;

  Future<void> _handleDownloadAndOpen() async {
    setState(() => _isDownloading = true);
    final notifier = ref.read(translationTaskProvider.notifier);
    final file = await notifier.downloadResult();
    if (!mounted) return;
    setState(() => _isDownloading = false);

    final strings = AppStrings.of(context);

    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.errorServerDown)),
      );
      return;
    }

    final result = await OpenFile.open(file.path);
    if (!mounted) return;
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.openFileFailed)),
      );
    }
  }

  Future<void> _handleOpenExistingFile() async {
    final state = ref.read(translationTaskProvider);
    final path = state.localDownloadedFilePath;
    if (path == null) return;
    final result = await OpenFile.open(path);
    if (!mounted) return;
    if (result.type != ResultType.done) {
      final strings = AppStrings.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.openFileFailed)),
      );
    }
  }

  void _handleNewTranslation() {
    ref.read(translationTaskProvider.notifier).reset();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _handleRetry() {
    ref.read(translationTaskProvider.notifier).reset();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final state = ref.watch(translationTaskProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: state.progress.status.isTerminal || !state.isUploading,
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.originalFileName ?? strings.appTitle),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TranslationProgressIndicator(
                      progress: state.progress,
                      isUploading: state.isUploading,
                    ),
                    const SizedBox(height: 40),
                    if (state.isCompleted) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isDownloading
                              ? null
                              : (state.localDownloadedFilePath != null
                                  ? _handleOpenExistingFile
                                  : _handleDownloadAndOpen),
                          icon: _isDownloading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(
                                  state.localDownloadedFilePath != null
                                      ? Icons.file_open_rounded
                                      : Icons.download_rounded,
                                ),
                          label: Text(
                            state.localDownloadedFilePath != null
                                ? strings.openFileButton
                                : strings.downloadButton,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _handleNewTranslation,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(strings.newTranslationButton),
                        ),
                      ),
                    ] else if (state.isFailed) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _handleRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(strings.retryButton),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(strings.cancelButton),
                        ),
                      ),
                    ] else ...[
                      TextButton(
                        onPressed: () {
                          ref.read(translationTaskProvider.notifier).reset();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          strings.cancelButton,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
