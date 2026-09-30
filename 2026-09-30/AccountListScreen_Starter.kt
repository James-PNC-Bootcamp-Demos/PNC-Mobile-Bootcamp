//
// AccountListScreen_Starter.kt
// Module 12 — Android UI Development
// Lab Exercise: PNC Mobile — Accounts List Screen (Jetpack Compose)
//
// SCENARIO
// Build the accounts list screen for PNC Mobile Android — the final screen
// for Module 12. This exercise pulls together state (Block 1), navigation
// (Block 3), LazyColumn (Block 4), accessibility (Block 6), and animation
// (Block 7).
//
// REQUIREMENTS
// 1. Build AccountListScreen using LazyColumn and Material 3 components.
// 2. Each row shows account name, masked account number, and balance.
// 3. Tapping a row calls onAccountClick(accountId) — wiring this to actual
//    Navigation Compose is assumed to happen in a NavHost elsewhere (not
//    part of this file).
// 4. Every row must be fully readable by TalkBack as ONE combined element,
//    not three separate announcements.
// 5. Add an AnimatedVisibility confirmation banner that appears briefly
//    after a simulated refresh (a button that toggles a "Refreshed!"
//    message is sufficient to demonstrate this).
//
// The Account model below is complete. Implement the two TODOs.
//

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import com.pnc.jetpackcomposedemos.Artist
import com.pnc.jetpackcomposedemos.ArtistCard
import com.pnc.jetpackcomposedemos.ArtistDetails
import androidx.compose.runtime.remember
import com.pnc.jetpackcomposedemos.ui.theme.JetpackComposeDemosTheme
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.foundation.lazy.items

// MARK: - Model (complete — no changes needed)

data class Account(
    val id: String,
    val name: String,
    val maskedNumber: String,
    val balance: Double
)

val sampleAccounts = listOf(
    Account("a1", "Everyday Checking", "\u2022\u2022\u2022\u2022 4471", 4281.16),
    Account("a2", "High Yield Savings", "\u2022\u2022\u2022\u2022 9902", 18340.50),
    Account("a3", "Rewards Credit Card", "\u2022\u2022\u2022\u2022 2216", -612.44)
)

// MARK: - TODO 1: AccountListScreen
@Composable
fun AccountListScreen(accounts: List<Account>, onAccountClick: (String) -> Unit) {
    // TODO: Show a "Refresh" button. When tapped, set a boolean state to
    // true, then use AnimatedVisibility to show a "Refreshed!" confirmation
    // banner (fadeIn/fadeOut) above the list.
    //
    // Below the banner, use a LazyColumn with items(accounts, key = { it.id })
    // to render an AccountRow for each account.
    var isClicked by remember { mutableStateOf(false) }


    // First Issue: LazyColumn must be wrapped in an item block.
    // Why? -> LazyColumn only renders currently visible items
    LazyColumn(
        modifier = Modifier
            .fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        item {
            // Second Issue: Animation Appears Instantly on my device.
            // Assumption is that it is not working on my target device but is functional the scenes
            AnimatedVisibility(
                modifier = Modifier
                    .background(MaterialTheme.colorScheme.tertiaryContainer)
                    .fillMaxSize(),
                visible = isClicked,
                enter = fadeIn(animationSpec = tween(500)),
                exit = fadeOut(animationSpec = tween(500))
            ) {
                Text(
                    text = "Refreshed!"
                )
            }
        }

        item {
            Button(
                onClick = { isClicked = true },
            ) {
                Text("Refresh")
            }
        }

        items (
            items = accounts,
            key = { it.id }
        ) {
            AccountRow(
                account = it,
                onClick = {

                }
            )
        }
    }
}

// MARK: - TODO 2: AccountRow

// Originally had two rows to more neatly sort the data,
@Composable
fun AccountRow(account: Account, onClick: () -> Unit) {
    // TODO: Lay out account.name, account.maskedNumber, and account.balance
    // in a Row/Column combination. Use MaterialTheme.typography styles only
    // — no hard-coded font sizes. Add
    // Modifier.semantics(mergeDescendants = true) {} and a single,
    // readable contentDescription for the whole row.
    Column(
        modifier = Modifier.padding(16.dp)
    ){
        Row(
            horizontalArrangement = Arrangement.spacedBy(16.dp),
            modifier = Modifier.
            semantics(mergeDescendants = true) {
                contentDescription = "Account: ${account.name} ending in ${account.maskedNumber} has " +
                        "a balance of $${account.balance}."
            }
        ){
            Text(
                text = account.name,
                style = MaterialTheme.typography.titleLarge
            )
            Text(
                text = "$${account.balance}",
                style = MaterialTheme.typography.titleLarge
            )
            Text(
                text = account.maskedNumber
            )
        }
    }


}


@Preview(showBackground = true)
@Composable
fun ArtistDetailsPreview() {
    JetpackComposeDemosTheme {
        AccountListScreen(accounts = sampleAccounts, onAccountClick = { })
    }
}