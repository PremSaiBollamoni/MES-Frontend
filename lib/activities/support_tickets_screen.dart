import 'package:flutter/material.dart';
import '../components/app_button.dart' show AppPrimaryButton;
import '../components/app_text_field.dart';
import '../components/custom_toast.dart';
import '../services/support_api_service.dart';
import '../utils/theme_tokens.dart';

class SupportTicketsScreen extends StatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  State<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends State<SupportTicketsScreen> {
  final SupportApiService _apiService = SupportApiService();
  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final tickets = await _apiService.listTickets(forceRefresh: forceRefresh);
      setState(() {
        _tickets = tickets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "$e";
        _isLoading = false;
      });
    }
  }

  Future<void> _resolve(SupportTicket ticket) async {
    final notesController = TextEditingController(text: ticket.resolutionNotes ?? "");
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ThemeTokens.surfaceSolid,
        title: Text("Resolve Ticket", style: ThemeTokens.headingMedium),
        content: AppTextField(controller: notesController, label: "Resolution notes", maxLines: 4),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("Cancel")),
          AppPrimaryButton(label: "Mark Resolved", onPressed: () => Navigator.of(context).pop(true)),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _apiService.resolveTicket(ticket.id, notesController.text.trim());
      if (mounted) CustomToast.show(context, "Ticket resolved");
      _load(forceRefresh: true);
    } catch (e) {
      if (mounted) CustomToast.show(context, "Couldn't resolve ticket: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeTokens.background,
      appBar: AppBar(
        title: Text("Support Tickets", style: ThemeTokens.headingMedium),
        backgroundColor: ThemeTokens.surfaceSolid,
        elevation: 0,
        actions: [
          IconButton(onPressed: () => _load(forceRefresh: true), icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _load(forceRefresh: true),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ThemeTokens.primary));
    }
    if (_error != null) {
      return Center(child: Text("Couldn't load tickets: $_error", style: ThemeTokens.bodyMedium));
    }
    if (_tickets.isEmpty) {
      return ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(40),
            child: Center(child: Text("No tickets raised yet", style: ThemeTokens.bodyMedium)),
          ),
        ],
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tickets.length,
      itemBuilder: (context, index) {
        final ticket = _tickets[index];
        final isOpen = ticket.status == "OPEN";
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ThemeTokens.surfaceSolid,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ThemeTokens.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(ticket.subject, style: ThemeTokens.bodyLarge)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOpen ? ThemeTokens.warning.withValues(alpha: 0.15) : ThemeTokens.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      ticket.status,
                      style: ThemeTokens.caption.copyWith(color: isOpen ? ThemeTokens.warning : ThemeTokens.success),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text("${ticket.employeeName} · ${ticket.createdAt}", style: ThemeTokens.caption),
              const SizedBox(height: 10),
              Text(ticket.description, style: ThemeTokens.bodyMedium),
              if (ticket.resolutionNotes != null && ticket.resolutionNotes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text("Resolution: ${ticket.resolutionNotes}", style: ThemeTokens.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
              ],
              if (isOpen) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _resolve(ticket),
                    child: const Text("Mark Resolved"),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
